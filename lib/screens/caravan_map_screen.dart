import 'package:flutter/material.dart';
import '../models/caravan_model.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../utils/app_colors.dart';
import '../widgets/caravan_map_painter.dart';
import '../widgets/sound_service.dart';
import 'caravan_shift_screen.dart';
import 'caravan_shop_screen.dart';
import 'daily_menu_dialog.dart';
import 'mystery_event_screen.dart';
import 'treasure_screen.dart';

class CaravanMapScreen extends StatefulWidget {
  const CaravanMapScreen({super.key});

  @override
  State<CaravanMapScreen> createState() => _CaravanMapScreenState();
}

class _CaravanMapScreenState extends State<CaravanMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _selectedNodeId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onNodeTapped(MapNode node) {
    if (!node.isAvailable || node.isCompleted) {
      if (node.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu durak zaten tamamlandı.'),
            duration: Duration(milliseconds: 900),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu durağa şu anki rotanızdan ulaşılamıyor.'),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
      return;
    }

    SoundService().playClick();
    setState(() {
      _selectedNodeId = node.id;
    });
  }

  void _startSelectedNode(ExpeditionState expedition) {
    if (_selectedNodeId == null) return;
    final node = expedition.nodes[_selectedNodeId];
    if (node == null) return;

    SoundService().playClick();
    final ok = expedition.selectNode(_selectedNodeId!);
    if (!ok) return;

    // Navigate to appropriate screen based on node type
    Widget destination;
    switch (node.type) {
      case MapNodeType.servingDay:
        destination = CaravanShiftScreen(
          isRushHour: false,
          isBossFestival: false,
          targetCustomerCount: 3 + node.layer,
        );
        break;
      case MapNodeType.rushHour:
        destination = CaravanShiftScreen(
          isRushHour: true,
          isBossFestival: false,
          targetCustomerCount: 4 + node.layer,
        );
        break;
      case MapNodeType.mysteryEvent:
        destination = const MysteryEventScreen();
        break;
      case MapNodeType.caravanShop:
        destination = const CaravanShopScreen();
        break;
      case MapNodeType.treasure:
        destination = const TreasureScreen();
        break;
      case MapNodeType.bossFestival:
        destination = CaravanShiftScreen(
          isRushHour: true,
          isBossFestival: true,
          targetCustomerCount: 6,
        );
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => destination),
    ).then((_) {
      setState(() {
        _selectedNodeId = null;
      });
      _checkRunEndConditions(expedition);
    });
  }

  void _checkRunEndConditions(ExpeditionState expedition) {
    if (expedition.isGameOver) {
      _showGameOverDialog(expedition);
    } else if (expedition.isRunCompleted) {
      _showVictoryDialog(expedition);
    }
  }

  void _showGameOverDialog(ExpeditionState expedition) {
    final earnedCoins = expedition.runCoins;
    final earnedXp = expedition.currentLayer * 50 + 40;
    GameState().recordExpeditionFinished(
      earnedCoins: earnedCoins,
      earnedXp: earnedXp,
      won: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Text('💔', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text('Karavan Yolda Kaldı', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Müşteri memnuniyetsizliği yüzünden karavanınızın itibarı tükendi ve bu sefer sona erdi.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kazanılan Altın:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$earnedCoins 💰', style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Kazanılan Deneyim:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$earnedXp XP ✨', style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldenCrema),
            onPressed: () {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // map screen -> back to home
            },
            child: const Text('Garaja Dön', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog(ExpeditionState expedition) {
    SoundService().playLevelUp();
    final earnedCoins = expedition.runCoins + 150;
    final earnedXp = 300;
    GameState().recordExpeditionFinished(
      earnedCoins: earnedCoins,
      earnedXp: earnedXp,
      won: true,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Text('🏆', style: TextStyle(fontSize: 32)),
            SizedBox(width: 10),
            Text('Festival Şampiyonu!', style: TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tebrikler! ${expedition.currentRegion.name} bölgesindeki kahve festivalinde tüm gurmeleri büyülediniz!',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldenCrema),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Festival Kazancı:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$earnedCoins 💰', style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ustalık Deneyimi:', style: TextStyle(color: AppColors.textMuted)),
                      Text('+$earnedXp XP ✨', style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldenCrema),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Zaferle Eve Dön', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();

    return ListenableBuilder(
      listenable: expedition,
      builder: (context, _) {
        final region = expedition.currentRegion;
        final selectedNode = _selectedNodeId != null ? expedition.nodes[_selectedNodeId] : null;

        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: SafeArea(
            child: Column(
              children: [
                // Top Expedition HUD Bar
                _buildTopHud(expedition, region),

                // Main Interactive Roguelite Map Area
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          // Background scenic map painter
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: CaravanMapPainter(
                                  nodes: expedition.nodes,
                                  currentNodeId: expedition.currentNodeId ?? _selectedNodeId,
                                  pulseValue: _pulseController.value,
                                  skyColor: region.skyColor,
                                  groundColor: region.groundColor,
                                ),
                              );
                            },
                          ),

                          // Tappable node overlay buttons
                          ...expedition.nodes.values.map((node) {
                            return _buildNodeTouchTarget(
                              node: node,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                              isSelected: node.id == _selectedNodeId,
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Caravan Control / Selected Node Action Card
                _buildBottomControl(expedition, selectedNode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHud(ExpeditionState expedition, CaravanRegion region) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.lightCrema),
                tooltip: 'Haritayı Kapat',
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(region.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          region.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldenCrema,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Gün ${(expedition.currentLayer + 1)} / ${ExpeditionState.totalLayers} • ${expedition.currentCaravan.name}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Reputation Hearts (Coffee Caravan Style)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: List.generate(ExpeditionState.maxHearts, (index) {
                    final hasHeart = index < expedition.reputationHearts;
                    return Text(
                      hasHeart ? '❤️' : '🖤',
                      style: const TextStyle(fontSize: 14),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),

              // Run Coins
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldenCrema.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${expedition.runCoins}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenCrema,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Active Relics & Menu Shortcut Bar
          Row(
            children: [
              // Daily Menu Chalkboard Button
              InkWell(
                onTap: () {
                  SoundService().playClick();
                  showDialog(
                    context: context,
                    builder: (context) => const DailyMenuDialog(),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3828),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        'Menü (${expedition.activeMenu.length})',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Relics list
              Expanded(
                child: SizedBox(
                  height: 24,
                  child: expedition.activeRelicIds.isEmpty
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Henüz yol yadigarı (relic) yok.',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: expedition.activeRelicIds.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 6),
                          itemBuilder: (context, index) {
                            final relic = CaravanRelic.findById(expedition.activeRelicIds[index]);
                            if (relic == null) return const SizedBox();
                            return Tooltip(
                              message: '${relic.name}: ${relic.description}',
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.bgDark,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderSubtle),
                                ),
                                child: Text(relic.icon, style: const TextStyle(fontSize: 14)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeTouchTarget({
    required MapNode node,
    required double width,
    required double height,
    required bool isSelected,
  }) {
    const double paddingX = 40.0;
    const double paddingY = 80.0;
    final double availableWidth = width - (paddingX * 2);
    final double availableHeight = height - (paddingY * 2);

    final double progressY = node.layer / (ExpeditionState.totalLayers - 1);
    final double posY = height - paddingY - (progressY * availableHeight);

    double posX;
    if (node.type == MapNodeType.bossFestival) {
      posX = width / 2;
    } else {
      posX = paddingX + (node.lane / 2.0) * availableWidth;
    }

    final double touchSize = node.type == MapNodeType.bossFestival ? 70.0 : 54.0;

    return Positioned(
      left: posX - (touchSize / 2),
      top: posY - (touchSize / 2),
      width: touchSize,
      height: touchSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onNodeTapped(node),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                node.type.icon,
                style: TextStyle(
                  fontSize: node.type == MapNodeType.bossFestival ? 30 : 22,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.goldenCrema,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('SEÇİLDİ', style: TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControl(ExpeditionState expedition, MapNode? selectedNode) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: selectedNode == null
          ? Row(
              children: [
                const Text('🚐', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Bir Sonraki Durağı Seçin',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13),
                      ),
                      Text(
                        'Haritada parlayan uygun duraklardan birine tıklayın.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.goldenCrema),
                  ),
                  child: Text(selectedNode.type.icon, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedNode.type.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldenCrema,
                        ),
                      ),
                      Text(
                        selectedNode.type.shortDesc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldenCrema,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_car, size: 18),
                  label: const Text('YOLA ÇIK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  onPressed: () => _startSelectedNode(expedition),
                ),
              ],
            ),
    );
  }
}
