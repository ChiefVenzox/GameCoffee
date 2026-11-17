import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../models/customer_order.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';
import 'brewing_station_screen.dart';

class ShiftCustomer {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final CoffeeRecipe recipe;
  final int totalPatience;
  int currentPatience;
  bool isBeingServed;
  bool isFinishedDrinking;

  ShiftCustomer({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.recipe,
    required this.totalPatience,
    required this.currentPatience,
    this.isBeingServed = false,
    this.isFinishedDrinking = false,
  });
}

class CaravanShiftScreen extends StatefulWidget {
  final bool isRushHour;
  final bool isBossFestival;
  final int targetCustomerCount;

  const CaravanShiftScreen({
    super.key,
    required this.isRushHour,
    required this.isBossFestival,
    required this.targetCustomerCount,
  });

  @override
  State<CaravanShiftScreen> createState() => _CaravanShiftScreenState();
}

class _CaravanShiftScreenState extends State<CaravanShiftScreen>
    with SingleTickerProviderStateMixin {
  final List<ShiftCustomer> _waitingCustomers = [];
  int _customersSpawned = 0;
  int _customersServed = 0;
  int _earnedShiftCoins = 0;
  int _earnedShiftTips = 0;

  late int _cleanCups;
  int _dirtyCups = 0;
  bool _isWashingDishes = false;
  double _washProgress = 0.0;

  CoffeeRecipe? _brewedCoffeeOnTray;
  bool _isBrewingQuick = false;
  double _brewProgress = 0.0;

  Timer? _gameLoopTimer;
  Timer? _spawnTimer;

  @override
  void initState() {
    super.initState();
    final expedition = ExpeditionState();
    _cleanCups = expedition.maxCleanCups;

    // Start game loop timer for customer patience & dishwashing
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _tick();
    });

    // Initial spawn
    _spawnCustomer();

    // Periodic customer spawner
    final spawnInterval = widget.isRushHour ? 7 : 10;
    _spawnTimer = Timer.periodic(Duration(seconds: spawnInterval), (timer) {
      if (_customersSpawned < widget.targetCustomerCount) {
        _spawnCustomer();
      } else {
        _spawnTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _spawnCustomer() {
    if (_customersSpawned >= widget.targetCustomerCount || !mounted) return;

    final expedition = ExpeditionState();
    final random = Random();

    // Pick recipe strictly from the active daily menu
    final activeMenuIds = expedition.activeMenu;
    final availableRecipes = CoffeeRecipe.allRecipes
        .where((r) => activeMenuIds.contains(r.id))
        .toList();

    final selectedRecipe = availableRecipes.isNotEmpty
        ? availableRecipes[random.nextInt(availableRecipes.length)]
        : CoffeeRecipe.allRecipes.first;

    // Customer pool selection
    final customerData = CustomerOrder.customerPool[random.nextInt(CustomerOrder.customerPool.length)];

    // Calculate patience with buffs
    int basePatience = widget.isRushHour ? 32 : 45;
    if (widget.isBossFestival && _customersSpawned == widget.targetCustomerCount - 1) {
      basePatience = 55; // VIP Food Critic patience
    }
    final totalPatience = (basePatience * expedition.totalPatienceMultiplier).round();

    setState(() {
      _waitingCustomers.add(
        ShiftCustomer(
          id: 'cust_${DateTime.now().millisecondsSinceEpoch}_$_customersSpawned',
          name: widget.isBossFestival && _customersSpawned == widget.targetCustomerCount - 1
              ? '👑 Gurme Eleştirmen Jean'
              : customerData['name'] as String,
          role: widget.isBossFestival && _customersSpawned == widget.targetCustomerCount - 1
              ? 'Michelin Rehberi Baş Jüri'
              : customerData['role'] as String,
          avatar: widget.isBossFestival && _customersSpawned == widget.targetCustomerCount - 1
              ? '🧐'
              : customerData['avatar'] as String,
          recipe: selectedRecipe,
          totalPatience: totalPatience,
          currentPatience: totalPatience,
        ),
      );
      _customersSpawned++;
    });
  }

  void _tick() {
    if (!mounted) return;

    setState(() {
      final expedition = ExpeditionState();
      final List<ShiftCustomer> leftAngry = [];

      for (var customer in _waitingCustomers) {
        customer.currentPatience -= 1;
        if (customer.currentPatience <= 0) {
          leftAngry.add(customer);
        }
      }

      // Handle angry departures
      for (var angry in leftAngry) {
        _waitingCustomers.remove(angry);
        SoundService().playClick();
        expedition.loseHeart();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${angry.name} sabrı tükendi ve sinirle ayrıldı! (-1 ❤️)'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );

        if (expedition.reputationHearts <= 0) {
          _gameLoopTimer?.cancel();
          _spawnTimer?.cancel();
          Navigator.of(context).pop(); // Back to map where game over triggers
          return;
        }
      }

      // Check if all customers finished
      if (_customersServed + leftAngry.length >= widget.targetCustomerCount && _waitingCustomers.isEmpty) {
        _gameLoopTimer?.cancel();
        _spawnTimer?.cancel();
        _showShiftCompleteModal();
      }
    });
  }

  // --- DISHWASHING MECHANIC ---
  void _startWashingDishes() {
    if (_dirtyCups <= 0 || _isWashingDishes) return;

    SoundService().playClick();
    setState(() {
      _isWashingDishes = true;
      _washProgress = 0.0;
    });

    final expedition = ExpeditionState();
    final washDurationMs = (1200 / expedition.totalWashSpeedMultiplier).round();
    const intervalMs = 60;
    final step = intervalMs / washDurationMs;

    Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _washProgress += step;
        if (_washProgress >= 1.0) {
          timer.cancel();
          _isWashingDishes = false;
          _washProgress = 0.0;

          // Transfer dirty cups back to clean cups
          _cleanCups += _dirtyCups;
          _dirtyCups = 0;
          SoundService().playSuccess();
        }
      });
    });
  }

  // --- BREWING MECHANIC ---
  void _startQuickBrew(CoffeeRecipe recipe) {
    if (_cleanCups <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Temiz fincan kalmadı! Önce lavaboda bulaşıkları yıkayın.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isBrewingQuick || _brewedCoffeeOnTray != null) return;

    SoundService().playClick();
    setState(() {
      _isBrewingQuick = true;
      _brewProgress = 0.0;
    });

    final expedition = ExpeditionState();
    final brewDurationMs = (2000 / expedition.totalBrewSpeedMultiplier).round();
    const intervalMs = 100;
    final step = intervalMs / brewDurationMs;

    Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _brewProgress += step;
        if (_brewProgress >= 1.0) {
          timer.cancel();
          _isBrewingQuick = false;
          _brewProgress = 0.0;
          _cleanCups -= 1; // Consume one clean cup
          _brewedCoffeeOnTray = recipe;
          SoundService().playSuccess();
        }
      });
    });
  }

  void _openManualBrewStation(ShiftCustomer customer) async {
    if (_cleanCups <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Temiz fincan kalmadı! Önce bulaşıkları yıkayın.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Open detailed manual barista station
    final order = CustomerOrder(
      customerName: customer.name,
      role: customer.role,
      avatar: customer.avatar,
      dialogue: 'Karavanınızdan taze bir ${customer.recipe.turkishName} alabilir miyim?',
      recipe: customer.recipe,
      requestedBean: customer.recipe.defaultBean,
      requestedMilk: customer.recipe.idealMilk,
      requestedSyrup: customer.recipe.idealSyrup,
      requestedTopping: customer.recipe.idealTopping,
      requestedCup: customer.recipe.cupType,
      patienceSeconds: customer.currentPatience,
    );

    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BrewingStationScreen(
          customerOrder: order,
          targetRecipe: customer.recipe,
        ),
      ),
    );

    // If served through manual station
    if (res == true || true) {
      // Direct serve
      setState(() {
        _cleanCups -= 1;
        _brewedCoffeeOnTray = customer.recipe;
        _serveCustomer(customer);
      });
    }
  }

  void _serveCustomer(ShiftCustomer customer) {
    if (_brewedCoffeeOnTray == null) return;

    if (_brewedCoffeeOnTray!.id != customer.recipe.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Müşteri ${customer.recipe.turkishName} istedi, tepside ${_brewedCoffeeOnTray!.turkishName} var!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SoundService().playCoin();
    final expedition = ExpeditionState();

    // Calculate earnings
    final basePrice = customer.recipe.basePrice;
    int tip = (basePrice * 0.3 * expedition.totalTipMultiplier).round();
    if (widget.isRushHour) tip *= 2;
    if (widget.isBossFestival) tip += 30;

    final earnedThis = basePrice + tip;

    setState(() {
      _brewedCoffeeOnTray = null;
      _dirtyCups += 1; // Customer drinks and leaves dirty cup!
      _customersServed += 1;
      _earnedShiftCoins += earnedThis;
      _earnedShiftTips += tip;
      _waitingCustomers.remove(customer);
    });

    expedition.addRunCoins(earnedThis);

    // Check shift completion
    if (_customersServed >= widget.targetCustomerCount && _waitingCustomers.isEmpty) {
      _gameLoopTimer?.cancel();
      _spawnTimer?.cancel();
      _showShiftCompleteModal();
    }
  }

  void _showShiftCompleteModal() {
    SoundService().playSuccess();
    final expedition = ExpeditionState();
    final xpEarned = (_customersServed * 30) + (widget.isBossFestival ? 150 : 50);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(widget.isBossFestival ? '🏆' : '🚐', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(
              widget.isBossFestival ? 'Festival Tamamlandı!' : 'Mola Servisi Tamamlandı!',
              style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günün servisi başarıyla tamamlandı. Karavanınız yola çıkmaya hazır!',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Servis Edilen Müşteri:', style: TextStyle(color: AppColors.textMuted)),
                      Text('$_customersServed Müşteri', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kazanılan Toplam Gelir:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$_earnedShiftCoins 💰', style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dahil Olan Bahşişler:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$_earnedShiftTips 💰', style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kazanılan Deneyim:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$xpEarned XP ✨', style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldenCrema,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss dialog
              expedition.completeCurrentNode(coinsEarned: 0, xpEarned: xpEarned);
              GameState().addReward(earnedCoins: _earnedShiftCoins, earnedXp: xpEarned, stars: 5);
              Navigator.of(context).pop(); // Back to Caravan Map
            },
            child: const Text('Yola Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar: Day, Hearts, Cups, Target
            _buildShiftHeader(expedition),

            // Customer Queue / Caravan Patio View
            Expanded(
              flex: 5,
              child: _buildCustomerQueueArea(),
            ),

            // Caravan Kitchen Counter & Dishwashing Station
            Expanded(
              flex: 6,
              child: _buildCaravanKitchenArea(expedition),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftHeader(ExpeditionState expedition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hearts
          Row(
            children: List.generate(ExpeditionState.maxHearts, (index) {
              final active = index < expedition.reputationHearts;
              return Text(active ? '❤️' : '🖤', style: const TextStyle(fontSize: 16));
            }),
          ),

          // Shift title badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: widget.isBossFestival
                  ? Colors.purple.withValues(alpha: 0.3)
                  : (widget.isRushHour
                      ? Colors.orange.withValues(alpha: 0.3)
                      : Colors.green.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isBossFestival
                    ? Colors.purpleAccent
                    : (widget.isRushHour ? Colors.orangeAccent : Colors.greenAccent),
              ),
            ),
            child: Text(
              widget.isBossFestival
                  ? '🏆 BÖLGE FESTİVALİ'
                  : (widget.isRushHour ? '🔥 YOĞUN SAAT' : '☕ KAHVE MOLASI'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.isBossFestival
                    ? Colors.purpleAccent
                    : (widget.isRushHour ? Colors.orangeAccent : Colors.greenAccent),
              ),
            ),
          ),

          // Quota & Coins
          Row(
            children: [
              Text(
                '$_customersServed/${widget.targetCustomerCount} 👥',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.goldenCrema),
                ),
                child: Text(
                  '+$_earnedShiftCoins 💰',
                  style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerQueueArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C271E), // Outdoor grass / picnic area
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🚐 Karavan Servis Penceresi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
              ),
              Text(
                'Bekleyen: ${_waitingCustomers.length}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _waitingCustomers.isEmpty
                ? const Center(
                    child: Text(
                      'Yeni müşteri bekleniyor... ☕',
                      style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _waitingCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _waitingCustomers[index];
                      final patienceRatio = customer.currentPatience / customer.totalPatience;

                      return Container(
                        width: 175,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: patienceRatio < 0.3
                                ? Colors.redAccent
                                : (patienceRatio < 0.6 ? Colors.orangeAccent : AppColors.borderSubtle),
                            width: patienceRatio < 0.3 ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Patience Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: patienceRatio.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  patienceRatio < 0.3
                                      ? Colors.redAccent
                                      : (patienceRatio < 0.6 ? Colors.orangeAccent : Colors.greenAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Avatar & Name
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(customer.avatar, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    customer.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Order bubble
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(customer.recipe.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      customer.recipe.turkishName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.goldenCrema,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Serve Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brewedCoffeeOnTray?.id == customer.recipe.id
                                    ? Colors.green
                                    : AppColors.bgCardLight,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                minimumSize: const Size(double.infinity, 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                if (_brewedCoffeeOnTray?.id == customer.recipe.id) {
                                  _serveCustomer(customer);
                                } else {
                                  _openManualBrewStation(customer);
                                }
                              },
                              child: Text(
                                _brewedCoffeeOnTray?.id == customer.recipe.id ? 'VER (Servis Et)' : 'Hassas Demle',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaravanKitchenArea(ExpeditionState expedition) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: AppColors.bgDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Clean cups & Dirty dishes rack (The Coffee Caravan Loop)
          Row(
            children: [
              // Clean Cups Rack
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cleanCups > 0 ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.redAccent),
                  ),
                  child: Row(
                    children: [
                      const Text('☕', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Temiz Fincanlar', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          Text(
                            '$_cleanCups / ${expedition.maxCleanCups}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _cleanCups > 0 ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Dirty Dishes & Sink (Tap to wash)
              Expanded(
                flex: 6,
                child: InkWell(
                  onTap: _dirtyCups > 0 && !_isWashingDishes ? _startWashingDishes : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _dirtyCups > 0 ? const Color(0xFF35201A) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _dirtyCups > 0 ? Colors.orangeAccent : AppColors.borderSubtle,
                        width: _dirtyCups > 0 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(_isWashingDishes ? '🧼' : '🚰', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isWashingDishes ? 'Yıkanıyor...' : 'Lavabo (Kirli: $_dirtyCups)',
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              if (_isWashingDishes)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: _washProgress,
                                    minHeight: 5,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                                  ),
                                )
                              else
                                Text(
                                  _dirtyCups > 0 ? 'DOKUN & YIKA 💧' : 'Temiz ✨',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _dirtyCups > 0 ? Colors.orangeAccent : Colors.greenAccent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Prepared Coffee Serving Tray
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('🛎️ Servis Tepsisi: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(width: 6),
                if (_brewedCoffeeOnTray != null) ...[
                  Text(_brewedCoffeeOnTray!.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Text(
                    _brewedCoffeeOnTray!.turkishName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema, fontSize: 13),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    tooltip: 'Tepsiyi Boşalt',
                    onPressed: () {
                      setState(() {
                        _dirtyCups += 1; // Discarding creates dirty cup
                        _brewedCoffeeOnTray = null;
                      });
                    },
                  ),
                ] else if (_isBrewingQuick) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kahve Akıyor... ⏳', style: TextStyle(fontSize: 11, color: AppColors.lightCrema)),
                        const SizedBox(height: 3),
                        LinearProgressIndicator(
                          value: _brewProgress,
                          minHeight: 5,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldenCrema),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const Text('Tepsi boş. Aşağıdan bir kahve seçip demleyin.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Fast Brew Bar (Active Menu Shortcuts)
          const Text(
            '⚡ Hızlı Demleme İstasyonları (Günün Menüsü)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: expedition.activeMenu.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final recipeId = expedition.activeMenu[index];
                final recipe = CoffeeRecipe.allRecipes.firstWhere((r) => r.id == recipeId);

                return SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgCard,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    onPressed: _cleanCups > 0 && !_isBrewingQuick && _brewedCoffeeOnTray == null
                        ? () => _startQuickBrew(recipe)
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(recipe.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          recipe.turkishName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${recipe.basePrice} 💰',
                          style: const TextStyle(fontSize: 10, color: AppColors.goldenCrema),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
