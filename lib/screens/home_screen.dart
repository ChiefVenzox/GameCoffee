import 'package:flutter/material.dart';
import '../models/caravan_model.dart';
import '../models/coffee_recipe.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';
import '../widgets/steam_animation.dart';
import 'brewing_station_screen.dart';
import 'caravan_garage_screen.dart';
import 'caravan_map_screen.dart';
import 'daily_menu_dialog.dart';
import 'recipe_book_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startNewExpedition(BuildContext context, String regionId) {
    SoundService().playClick();
    final gameState = GameState();
    final expedition = ExpeditionState();

    final tier = CaravanTier.allTiers.firstWhere(
      (t) => t.id.name == gameState.activeCaravanTierId,
      orElse: () => CaravanTier.allTiers.first,
    );

    expedition.startNewRun(
      regionId: regionId,
      tierId: tier.id,
      initialUnlockedRecipes: gameState.unlockedRecipeIds,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CaravanMapScreen()),
    );
  }

  void _showRegionSelectDialog(BuildContext context) {
    SoundService().playClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('🗺️', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text(
                      'Sefer Bölgesi Seçin',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenCrema,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...CaravanRegion.allRegions.map((region) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                      tileColor: AppColors.bgDark,
                      leading: Text(region.icon, style: const TextStyle(fontSize: 26)),
                      title: Text(region.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text(region.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightCrema),
                      onTap: () {
                        Navigator.of(context).pop();
                        _startNewExpedition(context, region.id);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startFreeBrewMode(BuildContext context) {
    SoundService().playClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎨 Serbest Deneme Kahvesi Seç',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldenCrema,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: CoffeeRecipe.allRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = CoffeeRecipe.allRecipes[index];
                      return ListTile(
                        leading: Text(recipe.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(recipe.turkishName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(recipe.brewMethod.displayName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BrewingStationScreen(
                                targetRecipe: recipe,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();
    final expedition = ExpeditionState();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.goldenCrema),
                        ),
                        child: const Text('🚐', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'COFFEE CARAVAN',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.goldenCrema,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Mobil Kafe & Roguelite Macerası',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.lightCrema),
                    onPressed: () {
                      SoundService().playClick();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Player Barista Card
              ListenableBuilder(
                listenable: gameState,
                builder: (context, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1A0F), Color(0xFF160E08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Stack(
                          alignment: Alignment.center,
                          children: [
                            Text('🧑‍🍳', style: TextStyle(fontSize: 38)),
                            Positioned(
                              top: -4,
                              child: SteamAnimation(height: 18, steamColor: Colors.white54),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gameState.baristaTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldenCrema,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Seviye ${gameState.level} Barista • ${gameState.totalCoffeesServed} Kahve Servis Edildi',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: gameState.levelProgress,
                                  minHeight: 4,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldenCrema),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.bgDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.goldenCrema),
                          ),
                          child: Row(
                            children: [
                              const Text('💰', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '${gameState.coins}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // HERO CARAVAN EXPEDITION CARD (The Coffee Caravan Loop)
              ListenableBuilder(
                listenable: expedition,
                builder: (context, _) {
                  final isRunActive = expedition.isRunActive;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isRunActive
                            ? [const Color(0xFF1B3828), const Color(0xFF2E4B34)]
                            : [const Color(0xFFC86432), const Color(0xFF6B3012)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (isRunActive ? Colors.green : Colors.deepOrange).withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isRunActive ? 'AKTİF SEFER SÜRÜYOR' : 'ROGUELITE SEFERİ',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            if (isRunActive)
                              Row(
                                children: List.generate(ExpeditionState.maxHearts, (i) {
                                  return Text(i < expedition.reputationHearts ? '❤️' : '🖤', style: const TextStyle(fontSize: 13));
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(isRunActive ? '🗺️' : '🚐', style: const TextStyle(fontSize: 32)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isRunActive ? expedition.currentRegion.name : 'Kahve Karavanı Seferine Çık',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isRunActive
                                        ? 'Gün ${expedition.currentLayer + 1}/${ExpeditionState.totalLayers} • ${expedition.runCoins} Altın • ${expedition.activeRelicIds.length} Relic'
                                        : 'Rastgele haritada kasabaları gez, kahve yap, ekipmanını geliştir ve Festivale ulaş!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldenCrema,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: Icon(isRunActive ? Icons.map : Icons.play_arrow, size: 20),
                          label: Text(
                            isRunActive ? 'SEFER HARİTASINA GİT' : 'YENİ SEFER BAŞLAT',
                            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                          ),
                          onPressed: () {
                            if (isRunActive) {
                              SoundService().playClick();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const CaravanMapScreen()),
                              );
                            } else {
                              _showRegionSelectDialog(context);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Caravan Management Row (Garage & Daily Menu)
              Row(
                children: [
                  Expanded(
                    child: _buildHubCard(
                      title: 'Karavan Garajı',
                      subtitle: 'Filo & Modeller',
                      iconEmoji: '🚐',
                      onTap: () {
                        SoundService().playClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CaravanGarageScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHubCard(
                      title: 'Günün Menüsü',
                      subtitle: 'Tezgah Karatahtası',
                      iconEmoji: '📋',
                      onTap: () {
                        SoundService().playClick();
                        showDialog(
                          context: context,
                          builder: (context) => const DailyMenuDialog(),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Secondary Hub Row (Recipe Book & Free Brew)
              Row(
                children: [
                  Expanded(
                    child: _buildHubCard(
                      title: 'Tarif Defteri',
                      subtitle: 'Barista Akademisi',
                      iconEmoji: '📖',
                      onTap: () {
                        SoundService().playClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RecipeBookScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHubCard(
                      title: 'Serbest Barista',
                      subtitle: 'Latte Art & Deneme',
                      iconEmoji: '🎨',
                      onTap: () => _startFreeBrewMode(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Permanent Equipment Shop
              InkWell(
                onTap: () {
                  SoundService().playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ShopScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: const [
                      Text('🛍️', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kalıcı Barista & Ekipman Pazarı',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                            ),
                            Text(
                              'Değirmenler, özel çekirdekler ve fincan takımları',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightCrema),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required String iconEmoji,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
