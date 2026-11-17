import 'package:flutter/material.dart';
import '../models/caravan_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class CaravanGarageScreen extends StatefulWidget {
  const CaravanGarageScreen({super.key});

  @override
  State<CaravanGarageScreen> createState() => _CaravanGarageScreenState();
}

class _CaravanGarageScreenState extends State<CaravanGarageScreen> {
  void _unlockCaravan(CaravanTier tier) {
    final gameState = GameState();
    if (gameState.coins < tier.unlockPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli altın yok! Seferler tamamlayarak altın biriktirin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SoundService().playLevelUp();
    final ok = gameState.unlockCaravan(tier.id.name, tier.unlockPrice);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tier.name} satın alındı ve aktif karavan yapıldı! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  void _selectActiveCaravan(CaravanTier tier) {
    SoundService().playClick();
    GameState().setActiveCaravan(tier.id.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgCard,
        elevation: 0,
        title: Row(
          children: const [
            Text('🚐', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'KARAVAN GARAJI & FİLO',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.goldenCrema, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Garage Banner Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1A47), Color(0xFF1E120A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameState.baristaTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kazanılan Festivaller: ${gameState.totalExpeditionsWon} • Toplam Servis: ${gameState.totalCoffeesServed}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Mobil Kahve Karavanları',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightCrema),
            ),
            const SizedBox(height: 10),

            // Caravans List
            ...CaravanTier.allTiers.map((tier) {
              final isUnlocked = gameState.unlockedCaravanTierIds.contains(tier.id.name);
              final isActive = gameState.activeCaravanTierId == tier.id.name;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isActive
                        ? AppColors.goldenCrema
                        : (isUnlocked ? Colors.white24 : AppColors.borderSubtle),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: tier.primaryColor.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: tier.accentColor),
                          ),
                          child: Text(tier.icon, style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tier.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.goldenCrema,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'AKTİF',
                                        style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tier.title,
                                style: const TextStyle(fontSize: 11, color: AppColors.goldenCrema),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(
                      tier.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),

                    const SizedBox(height: 12),

                    // Perks Grid
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildPerkChip('☕ ${tier.maxCleanCups} Fincan Kapasitesi'),
                        _buildPerkChip('⚡ Demleme Hızı: +${((tier.brewSpeedMultiplier - 1.0) * 100).toInt()}%'),
                        _buildPerkChip('💰 Bahşiş Çarpanı: +${((tier.tipBonusMultiplier - 1.0) * 100).toInt()}%'),
                        _buildPerkChip('⏳ Müşteri Sabrı: +${((tier.patienceBonusMultiplier - 1.0) * 100).toInt()}%'),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Action Button
                    if (isUnlocked)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? AppColors.goldenCrema : AppColors.bgCardLight,
                          foregroundColor: isActive ? Colors.black : Colors.white,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: isActive ? null : () => _selectActiveCaravan(tier),
                        child: Text(isActive ? 'Seferde Kullanılıyor' : 'Bu Karavanı Seç'),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gameState.coins >= tier.unlockPrice ? AppColors.goldenCrema : Colors.grey.shade800,
                          foregroundColor: gameState.coins >= tier.unlockPrice ? Colors.black : Colors.white38,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.lock_open, size: 16),
                        label: Text(
                          '${tier.unlockPrice} 💰 ile Satın Al',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _unlockCaravan(tier),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, color: AppColors.lightCrema),
      ),
    );
  }
}
