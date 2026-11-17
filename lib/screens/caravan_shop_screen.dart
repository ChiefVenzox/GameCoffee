import 'package:flutter/material.dart';
import '../models/caravan_model.dart';
import '../models/coffee_recipe.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class CaravanShopScreen extends StatefulWidget {
  const CaravanShopScreen({super.key});

  @override
  State<CaravanShopScreen> createState() => _CaravanShopScreenState();
}

class _CaravanShopScreenState extends State<CaravanShopScreen> {
  void _buyRelic(CaravanRelic relic) {
    final expedition = ExpeditionState();
    if (expedition.runCoins < relic.shopPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli altınınız yok!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SoundService().playCoin();
    expedition.spendRunCoins(relic.shopPrice);
    expedition.addRelic(relic.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${relic.name} karavana monte edildi!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {});
  }

  void _restoreHeart() {
    final expedition = ExpeditionState();
    const cost = 45;

    if (expedition.reputationHearts >= ExpeditionState.maxHearts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karavan itibarı zaten tam dolu! (3/3 ❤️)')),
      );
      return;
    }

    if (expedition.runCoins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeterli altınınız yok! (45 💰 gerekli)'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    SoundService().playSuccess();
    expedition.spendRunCoins(cost);
    expedition.gainHeart();
    setState(() {});
  }

  void _buyRecipe(CoffeeRecipe recipe) {
    final gameState = GameState();
    final expedition = ExpeditionState();
    const recipeCost = 60;

    if (expedition.runCoins < recipeCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeterli altınınız yok! (60 💰 gerekli)'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    SoundService().playSuccess();
    expedition.spendRunCoins(recipeCost);
    gameState.unlockRecipe(recipe.id, 0); // Unlocked permanently
    expedition.toggleMenuRecipe(recipe.id); // Add to active menu

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.turkishName} kilidi açıldı ve menüye eklendi!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {});
  }

  void _finishAndReturn() {
    final expedition = ExpeditionState();
    expedition.completeCurrentNode();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();
    final gameState = GameState();

    final unownedRelics = CaravanRelic.allRelics
        .where((r) => !expedition.activeRelicIds.contains(r.id))
        .toList();

    final lockedRecipes = CoffeeRecipe.allRecipes
        .where((r) => !gameState.isRecipeUnlocked(r.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text('🛒', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 8),
                      Text(
                        'KARAVAN PAZARI & MOLA YERİ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldenCrema,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldenCrema),
                    ),
                    child: Text(
                      '${expedition.runCoins} 💰',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
                    ),
                  ),
                ],
              ),
            ),

            // Shop Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Rest & Repair Heart
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('💖', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Karavan Bakımı & Dinlenme',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                              ),
                              Text(
                                'Karavan itibarını tazeler: +1 Kalp (${expedition.reputationHearts}/3)',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: expedition.reputationHearts < ExpeditionState.maxHearts ? _restoreHeart : null,
                          child: const Text('45 💰', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Caravan Relics Section
                  const Text(
                    '🪴 Karavan Yadigarları & Aksesuarlar (Relics)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
                  ),
                  const SizedBox(height: 8),

                  if (unownedRelics.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Bu seferde mevcut tüm yadigarları aldınız! Karavanınız dopdolu ✨',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  else
                    ...unownedRelics.map((relic) {
                      final canAfford = expedition.runCoins >= relic.shopPrice;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Text(relic.icon, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    relic.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  ),
                                  Text(
                                    relic.description,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? AppColors.goldenCrema : Colors.grey.shade800,
                                foregroundColor: canAfford ? Colors.black : Colors.white38,
                              ),
                              onPressed: canAfford ? () => _buyRelic(relic) : null,
                              child: Text('${relic.shopPrice} 💰', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 20),

                  // New Recipes Section
                  const Text(
                    '📖 Yeni Kahve Tarifleri Aç',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
                  ),
                  const SizedBox(height: 8),

                  if (lockedRecipes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Tüm kahve tariflerinin kilidi açık! Usta baristasınız 🏆',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    )
                  else
                    ...lockedRecipes.map((recipe) {
                      final canAfford = expedition.runCoins >= 60;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.turkishName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                                  ),
                                  Text(
                                    '${recipe.brewMethod.displayName} • Satış Fiyatı: ${recipe.basePrice} 💰',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? AppColors.goldenCrema : Colors.grey.shade800,
                                foregroundColor: canAfford ? Colors.black : Colors.white38,
                              ),
                              onPressed: canAfford ? () => _buyRecipe(recipe) : null,
                              child: const Text('60 💰', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Bottom Continue Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bgCard,
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenCrema,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('YOLCULUĞA DEVAM ET', style: TextStyle(fontWeight: FontWeight.w900)),
                onPressed: _finishAndReturn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
