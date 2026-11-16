import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../models/customer_order.dart';
import '../utils/app_colors.dart';
import '../widgets/coffee_cup_painter.dart';
import '../widgets/coffee_machine_widget.dart';
import '../widgets/customer_dialogue_widget.dart';
import '../widgets/grinder_widget.dart';
import '../widgets/sound_service.dart';
import '../widgets/steam_animation.dart';
import 'latte_art_screen.dart';
import 'order_result_screen.dart';

class BrewingStationScreen extends StatefulWidget {
  final CustomerOrder? customerOrder;
  final CoffeeRecipe targetRecipe;

  const BrewingStationScreen({
    super.key,
    this.customerOrder,
    required this.targetRecipe,
  });

  @override
  State<BrewingStationScreen> createState() => _BrewingStationScreenState();
}

class _BrewingStationScreenState extends State<BrewingStationScreen> {
  int _currentStep = 0; // 0: Beans & Cup, 1: Grinding, 2: Brewing, 3: Milk & Syrups, 4: Toppings & Serve

  late BeanType _selectedBean;
  late CupType _selectedCup;
  GrindLevel _achievedGrind = GrindLevel.fine;
  double _grindAccuracy = 1.0;
  double _brewAccuracy = 1.0;
  MilkType _selectedMilk = MilkType.none;
  FoamLevel _selectedFoam = FoamLevel.none;
  SyrupType _selectedSyrup = SyrupType.none;
  ToppingType _selectedTopping = ToppingType.none;
  List<Offset>? _latteArtPoints;

  double _cupFillLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedBean = widget.targetRecipe.defaultBean;
    _selectedCup = widget.targetRecipe.cupType;
    _selectedMilk = widget.targetRecipe.idealMilk;
    _selectedFoam = widget.targetRecipe.idealFoam;
    _selectedSyrup = widget.targetRecipe.idealSyrup;
    _selectedTopping = widget.targetRecipe.idealTopping;
  }

  void _onTimeExpired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Müşterinin sabrı tükendi! Hızlıca servis etmelisin.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _finishAndServe() {
    SoundService().playSuccess();

    final score = widget.targetRecipe.evaluate(
      selectedBean: _selectedBean,
      selectedGrind: _achievedGrind,
      extractionAccuracy: (_grindAccuracy * 0.4) + (_brewAccuracy * 0.6),
      selectedMilk: _selectedMilk,
      selectedFoam: _selectedFoam,
      selectedSyrup: _selectedSyrup,
      selectedTopping: _selectedTopping,
      selectedCup: _selectedCup,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderResultScreen(
          order: widget.customerOrder,
          recipe: widget.targetRecipe,
          score: score,
          bean: _selectedBean,
          milk: _selectedMilk,
          foam: _selectedFoam,
          syrup: _selectedSyrup,
          topping: _selectedTopping,
          cup: _selectedCup,
          latteArt: _latteArtPoints,
          onNextOrder: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  final newOrder = CustomerOrder.getRandomOrder();
                  return BrewingStationScreen(
                    customerOrder: newOrder,
                    targetRecipe: newOrder.recipe,
                  );
                },
              ),
            );
          },
          onHome: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(widget.targetRecipe.turkishName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Center(
              child: Text(
                'Adım ${_currentStep + 1}/5',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Customer Order Dialogue (if career mode)
            if (widget.customerOrder != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: CustomerDialogueWidget(
                  order: widget.customerOrder!,
                  onTimeExpired: _onTimeExpired,
                ),
              ),

            // Live Cup Preview Center Stage
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_cupFillLevel > 0.4 && !widget.targetRecipe.isCold)
                    const Positioned(
                      top: 4,
                      child: SteamAnimation(height: 50, width: 100),
                    ),
                  Positioned(
                    bottom: 8,
                    child: CoffeeCupWidget(
                      cupType: _selectedCup,
                      fillLevel: _cupFillLevel,
                      coffeeColor: widget.targetRecipe.defaultBean.color,
                      hasMilk: _selectedMilk != MilkType.none,
                      foamLevel: _selectedFoam,
                      topping: _selectedTopping,
                      hasIce: widget.targetRecipe.isCold,
                      latteArtPoints: _latteArtPoints,
                      width: 140,
                      height: 140,
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Navigation Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      onPressed: () {
                        SoundService().playClick();
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.goldenCrema),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Geri'),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        SoundService().playClick();
                        if (_currentStep < 4) {
                          setState(() {
                            _currentStep++;
                            if (_currentStep == 2 && _cupFillLevel == 0.0) {
                              _cupFillLevel = 0.5; // partial espresso fill
                            } else if (_currentStep >= 3) {
                              _cupFillLevel = 0.95; // full fill with milk
                            }
                          });
                        } else {
                          _finishAndServe();
                        }
                      },
                      icon: Icon(_currentStep == 4 ? Icons.coffee : Icons.arrow_forward),
                      label: Text(
                        _currentStep == 4 ? 'MÜŞTERİYE SERVİS ET ☕' : 'SONRAKİ ADIM',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStep == 4 ? Colors.green : AppColors.goldenCrema,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BeansAndCup();
      case 1:
        return _buildStep2Grinder();
      case 2:
        return _buildStep3Brewing();
      case 3:
        return _buildStep4MilkAndSyrups();
      case 4:
        return _buildStep5ToppingsAndArt();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: BEANS & CUP
  Widget _buildStep1BeansAndCup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Çekirdek Seçimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        ...BeanType.values.map((bean) {
          final isSelected = _selectedBean == bean;
          final isIdeal = widget.targetRecipe.defaultBean == bean;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.warmCoffee : AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.goldenCrema : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: bean.color, shape: BoxShape.circle),
              ),
              title: Text(bean.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: isIdeal
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Tarif İdeal', style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
                    )
                  : null,
              onTap: () {
                SoundService().playClick();
                setState(() {
                  _selectedBean = bean;
                });
              },
            ),
          );
        }),
        const SizedBox(height: 16),
        const Text(
          'Fincan / Bardak Sunumu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CupType.values.map((cup) {
            final isSelected = _selectedCup == cup;
            return ChoiceChip(
              label: Text(cup.displayName),
              selected: isSelected,
              onSelected: (_) {
                SoundService().playClick();
                setState(() {
                  _selectedCup = cup;
                });
              },
              selectedColor: AppColors.goldenCrema,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontSize: 12,
              ),
              backgroundColor: AppColors.bgCardLight,
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 2: GRINDER MINI-GAME
  Widget _buildStep2Grinder() {
    return GrinderWidget(
      beanType: _selectedBean,
      targetGrind: widget.targetRecipe.idealGrind,
      onGrindCompleted: (accuracy, resultGrind) {
        setState(() {
          _grindAccuracy = accuracy;
          _achievedGrind = resultGrind;
        });
      },
    );
  }

  // STEP 3: BREWING & EXTRACTION
  Widget _buildStep3Brewing() {
    return CoffeeMachineWidget(
      brewMethod: widget.targetRecipe.brewMethod,
      onBrewCompleted: (accuracy) {
        setState(() {
          _brewAccuracy = accuracy;
          _cupFillLevel = 0.55;
        });
      },
    );
  }

  // STEP 4: MILK & SYRUPS
  Widget _buildStep4MilkAndSyrups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🥛 Süt Tercihi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MilkType.values.map((milk) {
            final isSelected = _selectedMilk == milk;
            return ChoiceChip(
              label: Text(milk.displayName),
              selected: isSelected,
              onSelected: (_) {
                SoundService().playClick();
                setState(() {
                  _selectedMilk = milk;
                  if (milk != MilkType.none && _cupFillLevel < 0.8) {
                    _cupFillLevel = 0.85;
                  }
                });
              },
              selectedColor: AppColors.goldenCrema,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontSize: 12,
              ),
              backgroundColor: AppColors.bgCardLight,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          '☁️ Süt Köpüğü Yoğunluğu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FoamLevel.values.map((foam) {
            final isSelected = _selectedFoam == foam;
            return ChoiceChip(
              label: Text(foam.displayName),
              selected: isSelected,
              onSelected: (_) {
                SoundService().playFoamTick();
                setState(() {
                  _selectedFoam = foam;
                });
              },
              selectedColor: AppColors.goldenCrema,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontSize: 12,
              ),
              backgroundColor: AppColors.bgCardLight,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          '🍯 Şurup & Tatlandırıcı',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SyrupType.values.map((syrup) {
            final isSelected = _selectedSyrup == syrup;
            return ChoiceChip(
              label: Text(syrup.displayName),
              selected: isSelected,
              onSelected: (_) {
                SoundService().playClick();
                setState(() {
                  _selectedSyrup = syrup;
                });
              },
              selectedColor: AppColors.goldenCrema,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontSize: 12,
              ),
              backgroundColor: AppColors.bgCardLight,
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 5: TOPPINGS & LATTE ART
  Widget _buildStep5ToppingsAndArt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedMilk != MilkType.none) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.caramel.withValues(alpha: 0.3), AppColors.bgCardLight],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Latte Art Sanatı Yap',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _latteArtPoints != null ? 'Çizim Hazır ✓' : 'Fincan üzerine desen çiz!',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LatteArtScreen(
                          onFinished: () => Navigator.of(context).pop(),
                          onSaveArt: (points) {
                            setState(() {
                              _latteArtPoints = points;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenCrema,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Çiz'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        const Text(
          '✨ Süslemeler & Toppingler',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
        ),
        const SizedBox(height: 8),
        ...ToppingType.values.map((topping) {
          final isSelected = _selectedTopping == topping;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.warmCoffee : AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.goldenCrema : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ListTile(
              title: Text(topping.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              onTap: () {
                SoundService().playClick();
                setState(() {
                  _selectedTopping = topping;
                  _cupFillLevel = 1.0;
                });
              },
            ),
          );
        }),
      ],
    );
  }
}
