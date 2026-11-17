import 'package:flutter/material.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../models/mystery_event.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class MysteryEventScreen extends StatefulWidget {
  const MysteryEventScreen({super.key});

  @override
  State<MysteryEventScreen> createState() => _MysteryEventScreenState();
}

class _MysteryEventScreenState extends State<MysteryEventScreen> {
  late MysteryEvent _event;
  MysteryChoice? _selectedChoice;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _event = MysteryEvent.getRandom();
  }

  void _chooseOption(MysteryChoice choice) {
    final expedition = ExpeditionState();

    if (choice.coinCost > 0 && expedition.runCoins < choice.coinCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yeterli altınınız yok! Gerekli: ${choice.coinCost} 💰'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SoundService().playClick();

    if (choice.coinCost > 0) {
      expedition.spendRunCoins(choice.coinCost);
    }
    if (choice.coinReward > 0) {
      expedition.addRunCoins(choice.coinReward);
    }
    if (choice.heartDelta > 0) {
      expedition.gainHeart();
    } else if (choice.heartDelta < 0) {
      expedition.loseHeart();
    }
    if (choice.grantRelicId != null) {
      expedition.addRelic(choice.grantRelicId!);
      SoundService().playSuccess();
    }
    if (choice.xpReward > 0) {
      GameState().addReward(earnedCoins: 0, earnedXp: choice.xpReward, stars: 5);
    }

    setState(() {
      _selectedChoice = choice;
      _resolved = true;
    });
  }

  void _finishAndReturn() {
    final expedition = ExpeditionState();
    expedition.completeCurrentNode();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('❓', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        _event.subtitle,
                        style: const TextStyle(
                          color: AppColors.goldenCrema,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
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

              const SizedBox(height: 20),

              // Event Story Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(_event.avatar, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 12),
                        Text(
                          _event.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _event.narrative,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // If already resolved, show outcome
                        if (_resolved && _selectedChoice != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F3523),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.greenAccent),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '✨ Olayın Sonucu',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedChoice!.outcomeText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Choices list
                          ..._event.choices.map((choice) {
                            final canAfford = choice.coinCost == 0 || expedition.runCoins >= choice.coinCost;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canAfford ? AppColors.bgCardLight : Colors.black26,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: canAfford ? AppColors.goldenCrema.withValues(alpha: 0.6) : Colors.white12,
                                    ),
                                  ),
                                ),
                                onPressed: canAfford ? () => _chooseOption(choice) : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            choice.label,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                        if (choice.coinCost > 0)
                                          Text(
                                            '-${choice.coinCost} 💰',
                                            style: TextStyle(
                                              color: canAfford ? Colors.amberAccent : Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        if (choice.coinReward > 0)
                                          Text(
                                            '+${choice.coinReward} 💰',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      choice.description,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Button
              if (_resolved)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenCrema,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('YOLCULUĞA DEVAM ET', style: TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: _finishAndReturn,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
