import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../models/customer_order.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';
import '../widgets/steam_animation.dart';
import 'brewing_station_screen.dart';
import 'recipe_book_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _startCareerMode(BuildContext context) {
    SoundService().playClick();
    final order = CustomerOrder.getRandomOrder();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BrewingStationScreen(
          customerOrder: order,
          targetRecipe: order.recipe,
        ),
      ),
    );
  }

  void _startFreeBrewMode(BuildContext context) {
    SoundService().playClick();
    // Pick from a dialog or default to classic Latte
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
                  '🎨 Hazırlamak İstediğin Kahveyi Seç',
                  style: TextStyle(
                    fontSize: 18,
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
                        child: const Text('☕', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'BARISTA MASTER',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.goldenCrema,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Kahve Dükkanı Simülatörü',
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
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.warmCoffee,
                          AppColors.bgCard,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderSubtle, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gameState.baristaTitle,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldenCrema,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Seviye ${gameState.level} Barista',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Text('🪙', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${gameState.coins} ₺',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // XP Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Seviye İlerlemesi', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            Text(
                              '${(gameState.levelProgress * 100).toInt()}%',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: gameState.levelProgress,
                            backgroundColor: const Color(0xFF0F172A),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldenCrema),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Quick stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Servis Edilen', '${gameState.totalCoffeesServed} ☕'),
                            Container(width: 1, height: 24, color: AppColors.borderSubtle),
                            _buildStatItem('5 Yıldızlı', '${gameState.fiveStarCount} ⭐'),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Hero Interactive Banner (Cup with Steam)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF382315), Color(0xFF1E120A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 10,
                      child: SteamAnimation(height: 50, width: 90),
                    ),
                    Positioned(
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('☕', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 4),
                          Text(
                            'Taze Çekilmiş Çekirdek Aroması',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightCrema,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Game Action Cards
              // 1. Müşteri Kariyer Modu
              _buildMenuCard(
                title: 'MÜŞTERİ MODU (KARİYER)',
                subtitle: 'Siparişleri hazırla, müşteri sabrı bitmeden servis et ve bahşiş kazan!',
                iconEmoji: '🛎️',
                gradientColors: [const Color(0xFFD97706), const Color(0xFFB45309)],
                onTap: () => _startCareerMode(context),
                badge: 'ÖNERİLEN',
              ),
              const SizedBox(height: 14),

              // 2. Serbest Barista / Yaratıcı Mod
              _buildMenuCard(
                title: 'SERBEST BARİSTA (YARATICI)',
                subtitle: 'Süre baskısı yok! Tüm kahveleri dene, latte art çizimlerini geliştir.',
                iconEmoji: '🎨',
                gradientColors: [const Color(0xFF4A2810), const Color(0xFF26170E)],
                onTap: () => _startFreeBrewMode(context),
              ),
              const SizedBox(height: 14),

              // 3. Row with Shop and Recipe Book
              Row(
                children: [
                  Expanded(
                    child: _buildSmallCard(
                      title: 'Mağaza',
                      subtitle: 'Ekipman & Çekirdek',
                      iconEmoji: '🛍️',
                      onTap: () {
                        SoundService().playClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ShopScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallCard(
                      title: 'Tarif Rehberi',
                      subtitle: 'Kahve Akademisi',
                      iconEmoji: '📖',
                      onTap: () {
                        SoundService().playClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const RecipeBookScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Barista Trivia Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgCardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: const [
                    Text('💡', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Barista İpucu: Mükemmel bir espresso için su sıcaklığı 90-96°C, ekstraksiyon süresi ise 25-30 saniye olmalıdır!',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required String iconEmoji,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    String? badge,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(iconEmoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required String subtitle,
    required String iconEmoji,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
