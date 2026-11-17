import 'dart:math';
import 'package:flutter/material.dart';
import '../models/caravan_model.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class TreasureScreen extends StatefulWidget {
  const TreasureScreen({super.key});

  @override
  State<TreasureScreen> createState() => _TreasureScreenState();
}

class _TreasureScreenState extends State<TreasureScreen> {
  bool _claimed = false;
  String _claimedMessage = '';

  late final CaravanRelic _randomRelic;
  static const int goldReward = 75;

  @override
  void initState() {
    super.initState();
    final expedition = ExpeditionState();
    final unownedRelics = CaravanRelic.allRelics
        .where((r) => !expedition.activeRelicIds.contains(r.id))
        .toList();

    if (unownedRelics.isNotEmpty) {
      _randomRelic = unownedRelics[Random().nextInt(unownedRelics.length)];
    } else {
      _randomRelic = CaravanRelic.allRelics.first;
    }
  }

  void _claimRelic() {
    final expedition = ExpeditionState();
    expedition.addRelic(_randomRelic.id);
    SoundService().playSuccess();

    setState(() {
      _claimed = true;
      _claimedMessage = '${_randomRelic.name} sandıktan alındı ve karavana monte edildi!';
    });
  }

  void _claimGold() {
    final expedition = ExpeditionState();
    expedition.addRunCoins(goldReward);
    SoundService().playCoin();

    setState(() {
      _claimed = true;
      _claimedMessage = '+$goldReward Altın karavan kasasına eklendi!';
    });
  }

  void _claimHeartAndXp() {
    final expedition = ExpeditionState();
    expedition.gainHeart();
    GameState().addReward(earnedCoins: 0, earnedXp: 80, stars: 5);
    SoundService().playSuccess();

    setState(() {
      _claimed = true;
      _claimedMessage = 'Karavan bakımı yapıldı! +1 İtibar Kalbi ve +80 XP kazanıldı.';
    });
  }

  void _finishAndReturn() {
    final expedition = ExpeditionState();
    expedition.completeCurrentNode();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('🎁', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 8),
                  Text(
                    'TEDARİK SANDIĞI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldenCrema,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Yol kenarında bırakılmış bir barista sandığı buldunuz. Bir ödül seçin!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: _claimed
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F3523),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.greenAccent),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              const Text(
                                'Ödül Karavana Alındı!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _claimedMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Card 1: Relic
                          _buildRewardCard(
                            icon: _randomRelic.icon,
                            title: _randomRelic.name,
                            desc: _randomRelic.description,
                            tag: 'ÖZEL YADİGAR (RELIC)',
                            tagColor: Colors.amberAccent,
                            onTap: _claimRelic,
                          ),
                          const SizedBox(height: 14),

                          // Card 2: Gold Sack
                          _buildRewardCard(
                            icon: '💰',
                            title: 'Dolu Kese Altın',
                            desc: 'Hemen karavan kasasına +$goldReward Altın ekler.',
                            tag: 'NAKİT DESTEĞİ',
                            tagColor: AppColors.goldenCrema,
                            onTap: _claimGold,
                          ),
                          const SizedBox(height: 14),

                          // Card 3: Repair & XP
                          _buildRewardCard(
                            icon: '💖',
                            title: 'Karavan Bakımı & Dinlenme',
                            desc: '+1 İtibar Kalbi yeniler ve +80 XP kazandırır.',
                            tag: 'ONARIM & TECRÜBE',
                            tagColor: Colors.pinkAccent,
                            onTap: _claimHeartAndXp,
                          ),
                        ],
                      ),
              ),

              if (_claimed)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenCrema,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('HARİTAYA DÖN', style: TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: _finishAndReturn,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard({
    required String icon,
    required String title,
    required String desc,
    required String tag,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tagColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                shape: BoxShape.circle,
                border: Border.all(color: tagColor),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: tagColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.lightCrema),
          ],
        ),
      ),
    );
  }
}
