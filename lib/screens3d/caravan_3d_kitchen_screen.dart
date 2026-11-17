import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../engine3d/camera3d.dart';
import '../engine3d/mesh3d.dart';
import '../engine3d/models3d.dart';
import '../engine3d/renderer3d.dart';
import '../models/coffee_recipe.dart';
import '../models/customer_order.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

enum BaristaHandsItem {
  none,
  groundCoffee,
  brewedCup,
  dirtyCup,
}

class Customer3D {
  final String id;
  final String name;
  final String avatar;
  final CoffeeRecipe recipe;
  final int totalPatience;
  int currentPatience;
  vm.Vector3 position;
  bool isSeated;
  int tableIndex;
  bool hasDirtyCup;

  Customer3D({
    required this.id,
    required this.name,
    required this.avatar,
    required this.recipe,
    required this.totalPatience,
    required this.currentPatience,
    required this.position,
    this.isSeated = false,
    this.tableIndex = 0,
    this.hasDirtyCup = false,
  });
}

class Caravan3DKitchenScreen extends StatefulWidget {
  final bool isRushHour;
  final bool isBossFestival;
  final int targetCustomerCount;

  const Caravan3DKitchenScreen({
    super.key,
    required this.isRushHour,
    required this.isBossFestival,
    required this.targetCustomerCount,
  });

  @override
  State<Caravan3DKitchenScreen> createState() => _Caravan3DKitchenScreenState();
}

class _Caravan3DKitchenScreenState extends State<Caravan3DKitchenScreen>
    with SingleTickerProviderStateMixin {
  late Camera3D _camera;
  final Renderer3D _renderer = Renderer3D();

  // Barista 3D State
  final vm.Vector3 _baristaPos = vm.Vector3(0, 0, 0);
  double _baristaHeading = 0.0;
  double _walkCycle = 0.0;
  BaristaHandsItem _heldItem = BaristaHandsItem.none;
  CoffeeRecipe? _heldRecipe;

  // Virtual Joystick input
  Offset _joystickDelta = Offset.zero;

  // Station Coordinates in 3D Space
  final vm.Vector3 _grinderPos = vm.Vector3(-1.8, 0, -1.0);
  final vm.Vector3 _espressoPos = vm.Vector3(-0.6, 0, -1.2);
  final vm.Vector3 _sinkPos = vm.Vector3(1.2, 0, -1.2);

  // Outdoor Table positions (Customers sit here)
  final List<vm.Vector3> _tablePositions = [
    vm.Vector3(-2.6, 0, 2.8),
    vm.Vector3(0.4, 0, 3.2),
    vm.Vector3(2.8, 0, 2.6),
  ];

  // Customers in 3D
  final List<Customer3D> _customers = [];
  int _customersSpawned = 0;
  int _customersServed = 0;
  int _earnedCoins = 0;

  // Clean / Dirty Cup inventory
  late int _cleanCups;
  int _dirtyCups = 0;
  bool _isWashing = false;
  double _washTimer = 0.0;

  Timer? _gameLoop;
  Timer? _spawnTimer;

  @override
  void initState() {
    super.initState();
    final expedition = ExpeditionState();
    _cleanCups = expedition.maxCleanCups;

    // Isometric cozy camera
    _camera = Camera3D(
      position: vm.Vector3(7.5, 11.0, 9.5),
      target: vm.Vector3(0.0, 0.5, 0.8),
      isIsometric: true,
      orthoSize: 8.5,
    );

    // Initial customer spawn
    _spawnCustomer();

    // Spawner
    final intervalSec = widget.isRushHour ? 8 : 11;
    _spawnTimer = Timer.periodic(Duration(seconds: intervalSec), (timer) {
      if (_customersSpawned < widget.targetCustomerCount) {
        _spawnCustomer();
      } else {
        _spawnTimer?.cancel();
      }
    });

    // Main 60 FPS Game Loop
    _gameLoop = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      _updateGame(0.033);
    });
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _spawnCustomer() {
    if (_customersSpawned >= widget.targetCustomerCount || !mounted) return;

    // Find available table
    final occupiedTables = _customers.map((c) => c.tableIndex).toSet();
    int targetTable = -1;
    for (int i = 0; i < _tablePositions.length; i++) {
      if (!occupiedTables.contains(i)) {
        targetTable = i;
        break;
      }
    }
    if (targetTable == -1) return; // No free table

    final expedition = ExpeditionState();
    final random = Random();

    final activeMenu = expedition.activeMenu;
    final availableRecipes = CoffeeRecipe.allRecipes
        .where((r) => activeMenu.contains(r.id))
        .toList();
    final recipe = availableRecipes.isNotEmpty
        ? availableRecipes[random.nextInt(availableRecipes.length)]
        : CoffeeRecipe.allRecipes.first;

    final customerData = CustomerOrder.customerPool[random.nextInt(CustomerOrder.customerPool.length)];
    final basePatience = widget.isRushHour ? 35 : 50;
    final totalPatience = (basePatience * expedition.totalPatienceMultiplier).round();

    setState(() {
      _customers.add(
        Customer3D(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          name: customerData['name'] as String,
          avatar: customerData['avatar'] as String,
          recipe: recipe,
          totalPatience: totalPatience,
          currentPatience: totalPatience,
          position: _tablePositions[targetTable],
          isSeated: true,
          tableIndex: targetTable,
        ),
      );
      _customersSpawned++;
    });
  }

  void _updateGame(double dt) {
    if (!mounted) return;

    setState(() {
      // 1. Move Barista from joystick
      if (_joystickDelta != Offset.zero) {
        final speed = 4.2 * dt;
        // Project screen 2D joystick direction into 3D isometric plane
        final dx = _joystickDelta.dx;
        final dy = _joystickDelta.dy;

        // Isometric axis mapping
        final moveX = (dx + dy) * 0.7 * speed;
        final moveZ = (-dx + dy) * 0.7 * speed;

        _baristaPos.x = (_baristaPos.x + moveX).clamp(-3.2, 3.2);
        _baristaPos.z = (_baristaPos.z + moveZ).clamp(-2.0, 3.8);

        _baristaHeading = atan2(moveX, moveZ);
        _walkCycle += dt * 12.0;
      }

      // 2. Dishwashing progress
      if (_isWashing) {
        _washTimer += dt;
        if (_washTimer >= 1.2) {
          _isWashing = false;
          _washTimer = 0.0;
          _cleanCups += _dirtyCups;
          _dirtyCups = 0;
          SoundService().playSuccess();
        }
      }

      // 3. Customer patience ticks
      final expedition = ExpeditionState();
      final List<Customer3D> leavingAngry = [];

      for (var c in _customers) {
        if (!c.hasDirtyCup) {
          c.currentPatience = max(0, c.currentPatience - 1);
          if (c.currentPatience <= 0) {
            leavingAngry.add(c);
          }
        }
      }

      for (var angry in leavingAngry) {
        _customers.remove(angry);
        expedition.loseHeart();
        SoundService().playClick();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${angry.name} sabırsızlıktan ayrıldı! (-1 ❤️)'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );

        if (expedition.reputationHearts <= 0) {
          _gameLoop?.cancel();
          _spawnTimer?.cancel();
          Navigator.of(context).pop(); // Back to map where defeat dialog triggers
          return;
        }
      }

      // 4. Check if shift completed
      if (_customersServed + leavingAngry.length >= widget.targetCustomerCount && _customers.isEmpty) {
        _gameLoop?.cancel();
        _spawnTimer?.cancel();
        _showShiftEndModal();
      }
    });
  }

  // Station proximity checks
  bool _isNear(vm.Vector3 target, {double distance = 1.3}) {
    return (_baristaPos - target).length <= distance;
  }

  // --- 3D INTERACTION ACTIONS ---
  void _interactWithGrinder() {
    if (_heldItem != BaristaHandsItem.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elleriniz dolu! Önce elinizdeki nesneyi bırakın veya servis edin.')),
      );
      return;
    }

    SoundService().playGrinderTick();
    setState(() {
      _heldItem = BaristaHandsItem.groundCoffee;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚙️ Taze kahve çekirdekleri öğütüldü! Portafiltreye dolduruldu.'),
        duration: Duration(milliseconds: 900),
      ),
    );
  }

  void _interactWithEspressoMachine() {
    if (_heldItem != BaristaHandsItem.groundCoffee) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Önce değirmende kahve çekirdeği öğütmelisiniz!')),
      );
      return;
    }

    if (_cleanCups <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Temiz fincan kalmadı! Önce lavaboda bulaşıkları yıkayın.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    SoundService().playPourTick();
    final expedition = ExpeditionState();
    final recipe = CoffeeRecipe.allRecipes.firstWhere(
      (r) => expedition.activeMenu.contains(r.id),
      orElse: () => CoffeeRecipe.allRecipes.first,
    );

    setState(() {
      _cleanCups -= 1;
      _heldItem = BaristaHandsItem.brewedCup;
      _heldRecipe = recipe;
    });
    SoundService().playSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('☕ Taze ${recipe.turkishName} hazırlandı! Müşteriye servis edin.'),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _interactWithCustomer(Customer3D customer) {
    if (_heldItem == BaristaHandsItem.brewedCup) {
      // Serve coffee
      SoundService().playCoin();
      final expedition = ExpeditionState();
      final basePrice = customer.recipe.basePrice;
      int tip = (basePrice * 0.35 * expedition.totalTipMultiplier).round();
      if (widget.isRushHour) tip *= 2;

      final earned = basePrice + tip;
      _earnedCoins += earned;
      expedition.addRunCoins(earned);

      setState(() {
        _heldItem = BaristaHandsItem.none;
        _heldRecipe = null;
        customer.hasDirtyCup = true; // Customer finishes and leaves dirty cup
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ ${customer.name} kahvesini çok beğendi! +$earned 💰'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (customer.hasDirtyCup && _heldItem == BaristaHandsItem.none) {
      // Pick up dirty cup
      SoundService().playClick();
      setState(() {
        customer.hasDirtyCup = false;
        _heldItem = BaristaHandsItem.dirtyCup;
        _customers.remove(customer);
        _customersServed++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚰 Kirli fincan alındı. Lavaboda yıkayın!'),
          duration: Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _interactWithSink() {
    if (_heldItem == BaristaHandsItem.dirtyCup) {
      SoundService().playClick();
      setState(() {
        _heldItem = BaristaHandsItem.none;
        _dirtyCups += 1;
        _isWashing = true;
        _washTimer = 0.0;
      });
    } else if (_dirtyCups > 0 && !_isWashing) {
      SoundService().playClick();
      setState(() {
        _isWashing = true;
        _washTimer = 0.0;
      });
    }
  }

  void _showShiftEndModal() {
    SoundService().playSuccess();
    final expedition = ExpeditionState();
    final xp = (_customersServed * 40) + (widget.isBossFestival ? 200 : 60);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(widget.isBossFestival ? '🏆' : '🚐', style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(
              widget.isBossFestival ? '3D Festival Tamamlandı!' : '3D Gün Servisi Başarılı!',
              style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Karavanındaki tüm müşteriler memnuniyetle ayrıldı!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kazanılan Altın:', style: TextStyle(color: AppColors.textMuted)),
                  Text('+$_earnedCoins 💰', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldenCrema),
            onPressed: () {
              Navigator.of(context).pop();
              expedition.completeCurrentNode(coinsEarned: 0, xpEarned: xp);
              GameState().addReward(earnedCoins: _earnedCoins, earnedXp: xp, stars: 5);
              Navigator.of(context).pop(); // Back to Map
            },
            child: const Text('Yola Devam Et', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- BUILD 3D SCENE MESHES ---
  List<Mesh3D> _buildSceneMeshes() {
    final meshes = <Mesh3D>[];

    // 1. 3D Checkered Floor Tiles
    for (int x = -4; x <= 4; x++) {
      for (int z = -3; z <= 4; z++) {
        final isEven = (x + z) % 2 == 0;
        final tileColor = z < 0
            ? (isEven ? const Color(0xFF78350F) : const Color(0xFF92400E)) // Inside caravan wood floor
            : (isEven ? const Color(0xFF1E3A24) : const Color(0xFF24482C)); // Outdoor garden grass

        meshes.add(Mesh3D.createPlane(
          width: 0.98,
          depth: 0.98,
          color: tileColor,
          center: vm.Vector3(x.toDouble(), 0, z.toDouble()),
        ));
      }
    }

    // 2. 3D Caravan Model (Stationed at Z = -1.6)
    final caravan = Models3D.createCaravan();
    caravan.position = vm.Vector3(0, 0, -2.4);
    meshes.add(caravan);

    // 3. 3D Appliances inside / on caravan counter
    final grinder = Models3D.createGrinder();
    grinder.position = _grinderPos.clone();
    meshes.add(grinder);

    final espresso = Models3D.createEspressoMachine();
    espresso.position = _espressoPos.clone();
    meshes.add(espresso);

    final sink = Models3D.createSink(isRunningWater: _isWashing);
    sink.position = _sinkPos.clone();
    meshes.add(sink);

    final counter = Models3D.createCounter(width: 3.2, depth: 0.6);
    counter.position = vm.Vector3(0, 0, -1.2);
    meshes.add(counter);

    // 4. 3D Outdoor Bistro Tables & Chairs
    for (int i = 0; i < _tablePositions.length; i++) {
      final pos = _tablePositions[i];
      final table = Models3D.createBistroTable();
      table.position = pos.clone();
      meshes.add(table);

      // Chair
      final chair = Models3D.createChair();
      chair.position = vm.Vector3(pos.x, pos.y, pos.z + 0.6);
      meshes.add(chair);
    }

    // 5. 3D Barista Character
    final barista = Models3D.createBarista(
      walkCycle: _walkCycle,
      isHoldingCup: _heldItem == BaristaHandsItem.brewedCup || _heldItem == BaristaHandsItem.dirtyCup,
    );
    barista.position = _baristaPos.clone();
    barista.rotation = vm.Vector3(0, _baristaHeading, 0);
    meshes.add(barista);

    // 6. 3D Customers seated at tables
    for (var cust in _customers) {
      final custMesh = Models3D.createCustomer(
        outfitColor: const Color(0xFF0284C7),
        hairColor: const Color(0xFF713F12),
        isSitting: true,
      );
      custMesh.position = vm.Vector3(cust.position.x, cust.position.y, cust.position.z + 0.6);
      meshes.add(custMesh);
    }

    return meshes;
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();

    // Check proximities for contextual action buttons
    final nearGrinder = _isNear(_grinderPos);
    final nearEspresso = _isNear(_espressoPos);
    final nearSink = _isNear(_sinkPos);
    Customer3D? nearCustomer;
    for (var c in _customers) {
      if (_isNear(c.position, distance: 1.6)) {
        nearCustomer = c;
        break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // 3D Canvas
            GestureDetector(
              onPanUpdate: (details) {
                // Slight camera orbit on drag
                setState(() {
                  _camera.orbit(-details.delta.dx * 0.005, details.delta.dy * 0.005);
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _Kitchen3DPainter(
                  renderer: _renderer,
                  camera: _camera,
                  meshes: _buildSceneMeshes(),
                ),
              ),
            ),

            // Top Status Bar
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildTopStatus(expedition),
            ),

            // Projected 2D Speech Bubbles over 3D Customers
            ..._customers.map((cust) {
              return _buildProjectedCustomerBubble(cust);
            }),

            // Interactive Contextual Action Prompts (Bottom-Right)
            Positioned(
              bottom: 24,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grinder action
                  if (nearGrinder && _heldItem == BaristaHandsItem.none)
                    _buildActionButton(
                      label: '⚙️ ÇEKİRDEK ÖĞÜT',
                      color: const Color(0xFFD97706),
                      onTap: _interactWithGrinder,
                    ),

                  // Espresso machine action
                  if (nearEspresso && _heldItem == BaristaHandsItem.groundCoffee)
                    _buildActionButton(
                      label: '☕ KAHVE DEMLE',
                      color: Colors.green,
                      onTap: _interactWithEspressoMachine,
                    ),

                  // Customer action
                  if (nearCustomer != null)
                    _buildActionButton(
                      label: nearCustomer.hasDirtyCup ? '🚰 KİRLİ FİNCANI AL' : '🛎️ SİPARİŞİ VER',
                      color: nearCustomer.hasDirtyCup ? Colors.blueAccent : Colors.green,
                      onTap: () => _interactWithCustomer(nearCustomer!),
                    ),

                  // Sink action
                  if (nearSink)
                    _buildActionButton(
                      label: _isWashing ? '💧 YIKANIYOR...' : '🧼 BULAŞIKLARI YIKA',
                      color: Colors.cyan,
                      onTap: _isWashing ? null : _interactWithSink,
                    ),

                  const SizedBox(height: 8),

                  // Hands indicator badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldenCrema),
                    ),
                    child: Text(
                      _heldItem == BaristaHandsItem.none
                          ? 'El: Boş 🖐️'
                          : (_heldItem == BaristaHandsItem.groundCoffee
                              ? 'El: Taze Çekilmiş Kahve 🫘'
                              : (_heldItem == BaristaHandsItem.brewedCup
                                  ? 'El: ${_heldRecipe?.turkishName ?? "Kahve"} ☕'
                                  : 'El: Kirli Fincan 🚰')),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Virtual Joystick for Barista Movement (Bottom-Left)
            Positioned(
              bottom: 24,
              left: 20,
              child: _buildVirtualJoystick(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatus(ExpeditionState expedition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hearts
          Row(
            children: List.generate(ExpeditionState.maxHearts, (i) {
              return Text(i < expedition.reputationHearts ? '❤️' : '🖤', style: const TextStyle(fontSize: 14));
            }),
          ),

          // Clean Cups & Dirty Cups
          Row(
            children: [
              Text('☕ $_cleanCups/${expedition.maxCleanCups}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: _cleanCups > 0 ? Colors.greenAccent : Colors.redAccent,
                  )),
              const SizedBox(width: 8),
              if (_dirtyCups > 0)
                Text('🚰 $_dirtyCups kirli',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orangeAccent)),
            ],
          ),

          // Shift Quota & Coins
          Row(
            children: [
              Text('$_customersServed/${widget.targetCustomerCount} 👥',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              Text('+$_earnedCoins 💰',
                  style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectedCustomerBubble(Customer3D cust) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenPos = Renderer3D.worldToScreen(
          worldPos: vm.Vector3(cust.position.x, cust.position.y + 1.8, cust.position.z),
          camera: _camera,
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
        if (screenPos == null) return const SizedBox();

        final patienceRatio = cust.currentPatience / cust.totalPatience;

        return Positioned(
          left: screenPos.dx - 65,
          top: screenPos.dy - 35,
          child: Container(
            width: 130,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.bgCard.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cust.hasDirtyCup ? Colors.orangeAccent : AppColors.goldenCrema,
                width: 1.5,
              ),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cust.hasDirtyCup)
                  const Text('🚰 Kirli Fincan', style: TextStyle(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold))
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cust.recipe.emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          cust.recipe.turkishName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: patienceRatio,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        patienceRatio < 0.3 ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVirtualJoystick() {
    return GestureDetector(
      onPanUpdate: (details) {
        final offset = details.localPosition - const Offset(50, 50);
        final distance = offset.distance;
        if (distance > 0) {
          final clamped = offset / max(distance, 45.0);
          setState(() {
            _joystickDelta = clamped;
          });
        }
      },
      onPanEnd: (_) {
        setState(() {
          _joystickDelta = Offset.zero;
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Center(
          child: Transform.translate(
            offset: _joystickDelta * 30,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.goldenCrema,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
              ),
              child: const Icon(Icons.touch_app, size: 20, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
        ),
      ),
    );
  }
}

class _Kitchen3DPainter extends CustomPainter {
  final Renderer3D renderer;
  final Camera3D camera;
  final List<Mesh3D> meshes;

  _Kitchen3DPainter({
    required this.renderer,
    required this.camera,
    required this.meshes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    renderer.renderScene(
      canvas: canvas,
      size: size,
      camera: camera,
      meshes: meshes,
    );
  }

  @override
  bool shouldRepaint(covariant _Kitchen3DPainter oldDelegate) => true;
}
