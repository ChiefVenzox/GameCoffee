import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final soundService = SoundService();

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('İlerlemeyi Sıfırla?', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'Tüm biriken paralar, seviyeler ve satın alınan eşyalar sıfırlanacaktır. Emin misin?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal', style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            onPressed: () {
              GameState().resetProgress();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm ilerleme sıfırlandı.'), backgroundColor: Colors.orange),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('⚙️ Ayarlar & Sistem'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Audio & Haptics Section
            _buildSectionHeader('SES VE TİTREŞİM (MOBİL)'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Oyun Sesleri'),
                    subtitle: const Text('Öğütme, buhar, döküş sesleri', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: soundService.soundEnabled,
                    activeThumbColor: AppColors.goldenCrema,
                    onChanged: (val) {
                      setState(() {
                        soundService.toggleSound();
                      });
                    },
                  ),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  SwitchListTile(
                    title: const Text('Dokunsal Titreşim (Haptics)'),
                    subtitle: const Text('Android ve iOS motor titreşimleri', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    value: soundService.hapticsEnabled,
                    activeThumbColor: AppColors.goldenCrema,
                    onChanged: (val) {
                      setState(() {
                        soundService.toggleHaptics();
                      });
                      if (val) soundService.playSuccess();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // System & Architecture Section
            _buildSectionHeader('SİSTEM & PLATFORM UYUMLULUĞU'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildPlatformRow('Android Desteği', 'Android 5.0+ (API 21 - 34)', Icons.android, Colors.greenAccent),
                  const SizedBox(height: 12),
                  _buildPlatformRow('iOS Desteği', 'iOS 12.0+ (iPhone & iPad)', Icons.apple, Colors.white),
                  const SizedBox(height: 12),
                  _buildPlatformRow('Web & Desktop', 'Chrome, Safari, Edge, Linux', Icons.web, Colors.blueAccent),
                  const Divider(height: 24, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Framework Sürümü', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('Flutter 3.50 / Dart 3.14', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.goldenCrema)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader('VERİ YÖNETİMİ'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Oyun İlerlemesini Sıfırla', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                subtitle: const Text('Coins, XP ve mağaza eşyalarını sıfırlar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                onTap: _confirmReset,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.goldenCrema,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPlatformRow(String name, String detail, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
      ],
    );
  }
}
