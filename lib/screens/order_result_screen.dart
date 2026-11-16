import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../models/customer_order.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/coffee_cup_painter.dart';
import '../widgets/sound_service.dart';
import '../widgets/steam_animation.dart';

class OrderResultScreen extends StatefulWidget {
  final CustomerOrder? order;
  final CoffeeRecipe recipe;
  final BrewScore score;
  final BeanType bean;
  final MilkType milk;
  final FoamLevel foam;
  final SyrupType syrup;
  final ToppingType topping;
  final CupType cup;
  final List<Offset>? latteArt;
  final VoidCallback onNextOrder;
  final VoidCallback onHome;

  const OrderResultScreen({
    super.key,
    this.order,
    required this.recipe,
    required this.score,
    required this.bean,
    required this.milk,
    required this.foam,
    required this.syrup,
    required this.topping,
    required this.cup,
    this.latteArt,
    required this.onNextOrder,
    required this.onHome,
  });

  @override
  State<OrderResultScreen> createState() => _OrderResultScreenState();
}

class _OrderResultScreenState extends State<OrderResultScreen> {
  int _earnedCoins = 0;
  int _earnedXp = 0;

  @override
  void initState() {
    super.initState();
    _calculateAndApplyRewards();
  }

  void _calculateAndApplyRewards() {
    final base = widget.recipe.basePrice;
    final tip = (widget.score.stars * 8) + (widget.score.totalScore ~/ 10);
    _earnedCoins = base + tip;
    _earnedXp = widget.score.totalScore * 2;

    GameState().addReward(
      earnedCoins: _earnedCoins,
      earnedXp: _earnedXp,
      stars: widget.score.stars,
    );

    if (widget.score.stars >= 4) {
      SoundService().playSuccess();
    }
  }

  String get _customerReaction {
    if (widget.score.stars == 5) {
      return 'İnanılmaz bir lezzet! Hayatımda içtiğim en iyi kahvelerden biri!';
    } else if (widget.score.stars == 4) {
      return 'Çok lezzetli olmuş, elinize sağlık! Tekrar geleceğim.';
    } else if (widget.score.stars == 3) {
      return 'Fena değil, idare eder. Sıcaklığı ve aroması yerindeydi.';
    } else {
      return 'Hmm, istediğim gibi olmamış... Belki bir dahaki sefere daha iyi olur.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Header title
              Text(
                widget.score.stars >= 4 ? '🎉 MUHTEŞEM SUNUM!' : '☕ KAHVE SERVİS EDİLDİ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenCrema,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Visual Coffee Display with Steam
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!widget.recipe.isCold)
                      const Positioned(
                        top: 0,
                        child: SteamAnimation(height: 70, width: 140),
                      ),
                    Positioned(
                      bottom: 10,
                      child: CoffeeCupWidget(
                        cupType: widget.cup,
                        fillLevel: 1.0,
                        hasMilk: widget.milk != MilkType.none,
                        foamLevel: widget.foam,
                        topping: widget.topping,
                        hasIce: widget.recipe.isCold,
                        latteArtPoints: widget.latteArt,
                        width: 170,
                        height: 170,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Recipe Name
              Text(
                widget.recipe.turkishName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Star Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isFilled = index < widget.score.stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFilled ? AppColors.goldenCrema : const Color(0xFF475569),
                      size: 38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Total Score Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Text(
                  'Barista Puanı: %${widget.score.totalScore}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenCrema,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Customer Reaction Card (if career mode)
              if (widget.order != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.order!.avatar, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.order!.customerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '“$_customerReaction”',
                              style: const TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Feedback list
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Barista Değerlendirmesi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenCrema,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...widget.score.feedback.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.goldenCrema)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Rewards Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.caramel.withValues(alpha: 0.25),
                      AppColors.bgCard,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Kazanılan Gelir', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '+$_earnedCoins ₺',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: AppColors.borderSubtle),
                    Column(
                      children: [
                        const Text('Deneyim Puanı', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 6),
                            Text(
                              '+$_earnedXp XP',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldenCrema,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onHome,
                      icon: const Icon(Icons.home),
                      label: const Text('Ana Menü'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.goldenCrema),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onNextOrder,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(widget.order != null ? 'Sıradaki Müşteri' : 'Yeni Kahve Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldenCrema,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
