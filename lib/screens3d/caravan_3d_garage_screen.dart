import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../engine3d/camera3d.dart';
import '../engine3d/mesh3d.dart';
import '../engine3d/models3d.dart';
import '../engine3d/renderer3d.dart';
import '../models/caravan_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class Caravan3DGarageScreen extends StatefulWidget {
  const Caravan3DGarageScreen({super.key});

  @override
  State<Caravan3DGarageScreen> createState() => _Caravan3DGarageScreenState();
}

class _Caravan3DGarageScreenState extends State<Caravan3DGarageScreen> {
  late Camera3D _camera;
  final Renderer3D _renderer = Renderer3D();

  double _turntableRotation = 0.5; // in radians
  int _selectedTierIndex = 0;

  @override
  void initState() {
    super.initState();
    final gameState = GameState();
    _selectedTierIndex = CaravanTier.allTiers.indexWhere(
      (t) => t.id.name == gameState.activeCaravanTierId,
    );
    if (_selectedTierIndex == -1) _selectedTierIndex = 0;

    _camera = Camera3D(
      position: vm.Vector3(6.5, 5.0, 7.5),
      target: vm.Vector3(0, 1.2, 0),
      isIsometric: false, // Perspective camera for grand 3D showcase
      fov: 48 * pi / 180,
    );
  }

  Mesh3D _buildShowroomMesh(CaravanTier tier) {
    Color bodyColor;
    Color roofColor;
    Color trimColor;

    switch (tier.id) {
      case CaravanTierId.nomad:
        bodyColor = const Color(0xFF5A8F6A); // Mint Green
        roofColor = const Color(0xFFF7F2E7);
        trimColor = const Color(0xFFD97706);
        break;
      case CaravanTierId.vintageTruck:
        bodyColor = const Color(0xFF0284C7); // Retro Sky Blue
        roofColor = const Color(0xFFFFFFFF);
        trimColor = const Color(0xFFF59E0B);
        break;
      case CaravanTierId.artisanTrailer:
        bodyColor = const Color(0xFF9A3412); // Roasted Amber Copper
        roofColor = const Color(0xFFFEF3C7);
        trimColor = const Color(0xFFE2E8F0);
        break;
      case CaravanTierId.royalCruiser:
        bodyColor = const Color(0xFF312E81); // Royal Indigo Navy
        roofColor = const Color(0xFFFCD34D);
        trimColor = const Color(0xFFFBBF24);
        break;
    }

    final caravan = Models3D.createCaravan(
      bodyColor: bodyColor,
      roofColor: roofColor,
      trimColor: trimColor,
    );

    // Turntable wooden circular platform
    final platform = Mesh3D.createCylinder(
      radius: 3.2,
      height: 0.25,
      segments: 16,
      color: const Color(0xFF451A03), // Dark mahogany
      center: vm.Vector3(0, -0.12, 0),
    );

    final parts = [platform, caravan];
    final combined = Mesh3D.combine(parts);
    combined.rotation = vm.Vector3(0, _turntableRotation, 0);
    return combined;
  }

  void _unlockCaravan(CaravanTier tier) {
    final gameState = GameState();
    if (gameState.coins < tier.unlockPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeterli altın yok!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    SoundService().playLevelUp();
    final ok = gameState.unlockCaravan(tier.id.name, tier.unlockPrice);
    if (ok) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tier.name} satın alındı! 🎉'), backgroundColor: Colors.green),
      );
    }
  }

  void _selectActive(CaravanTier tier) {
    SoundService().playClick();
    GameState().setActiveCaravan(tier.id.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gameState = GameState();
    final currentTier = CaravanTier.allTiers[_selectedTierIndex];
    final isUnlocked = gameState.unlockedCaravanTierIds.contains(currentTier.id.name);
    final isActive = gameState.activeCaravanTierId == currentTier.id.name;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    children: const [
                      Text(
                        '3D KARAVAN GARAJI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.goldenCrema,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '360° Döndürmek için parmağınızla kaydırın',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                      '${gameState.coins} 💰',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
                    ),
                  ),
                ],
              ),
            ),

            // 3D Turntable View Area
            Expanded(
              flex: 6,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _turntableRotation += details.delta.dx * 0.015;
                  });
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _Showroom3DPainter(
                    renderer: _renderer,
                    camera: _camera,
                    mesh: _buildShowroomMesh(currentTier),
                  ),
                ),
              ),
            ),

            // Model Selector Dots & Name
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(CaravanTier.allTiers.length, (idx) {
                  final isSelected = idx == _selectedTierIndex;
                  return GestureDetector(
                    onTap: () {
                      SoundService().playClick();
                      setState(() {
                        _selectedTierIndex = idx;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: isSelected ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.goldenCrema : Colors.white24,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Bottom Caravan Specs Card
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, -4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentTier.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.goldenCrema,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('AKTİF KARAVAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(currentTier.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),

                    // Specs chips
                    Wrap(
                      spacing: 8,
                      children: [
                        _specChip('☕ ${currentTier.maxCleanCups} Fincan'),
                        _specChip('⚡ Hız: +${((currentTier.brewSpeedMultiplier - 1.0) * 100).toInt()}%'),
                        _specChip('💰 Bahşiş: +${((currentTier.tipBonusMultiplier - 1.0) * 100).toInt()}%'),
                        _specChip('⏳ Sabır: +${((currentTier.patienceBonusMultiplier - 1.0) * 100).toInt()}%'),
                      ],
                    ),

                    const Spacer(),

                    // Action Button
                    if (isUnlocked)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? AppColors.goldenCrema : AppColors.bgCardLight,
                          foregroundColor: isActive ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isActive ? null : () => _selectActive(currentTier),
                        child: Text(isActive ? 'Seferde Kullanılıyor' : 'Bu Karavanı Seç', style: const TextStyle(fontWeight: FontWeight.bold)),
                      )
                    else
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gameState.coins >= currentTier.unlockPrice ? AppColors.goldenCrema : Colors.grey.shade800,
                          foregroundColor: gameState.coins >= currentTier.unlockPrice ? Colors.black : Colors.white38,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.lock_open, size: 18),
                        label: Text('${currentTier.unlockPrice} 💰 ile Satın Al', style: const TextStyle(fontWeight: FontWeight.w900)),
                        onPressed: () => _unlockCaravan(currentTier),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.lightCrema)),
    );
  }
}

class _Showroom3DPainter extends CustomPainter {
  final Renderer3D renderer;
  final Camera3D camera;
  final Mesh3D mesh;

  _Showroom3DPainter({
    required this.renderer,
    required this.camera,
    required this.mesh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    renderer.renderScene(
      canvas: canvas,
      size: size,
      camera: camera,
      meshes: [mesh],
    );
  }

  @override
  bool shouldRepaint(covariant _Showroom3DPainter oldDelegate) => true;
}
