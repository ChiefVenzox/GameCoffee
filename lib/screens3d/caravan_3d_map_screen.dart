import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import '../engine3d/camera3d.dart';
import '../engine3d/mesh3d.dart';
import '../engine3d/models3d.dart';
import '../engine3d/renderer3d.dart';
import '../models/expedition_model.dart';
import '../models/game_state.dart';
import '../screens/caravan_shop_screen.dart';
import '../screens/daily_menu_dialog.dart';
import '../screens/mystery_event_screen.dart';
import '../screens/treasure_screen.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';
import 'caravan_3d_kitchen_screen.dart';

class Caravan3DMapScreen extends StatefulWidget {
  const Caravan3DMapScreen({super.key});

  @override
  State<Caravan3DMapScreen> createState() => _Caravan3DMapScreenState();
}

class _Caravan3DMapScreenState extends State<Caravan3DMapScreen>
    with SingleTickerProviderStateMixin {
  late Camera3D _camera;
  final Renderer3D _renderer = Renderer3D();

  String? _selectedNodeId;
  vm.Vector3 _caravanPos = vm.Vector3(0, 0, 0);

  @override
  void initState() {
    super.initState();
    // 3D Isometric Overview Camera
    _camera = Camera3D(
      position: vm.Vector3(12.0, 16.0, 14.0),
      target: vm.Vector3(0.0, 1.0, 0.0),
      isIsometric: true,
      orthoSize: 14.0,
    );

    _updateCaravanPos();
  }

  void _updateCaravanPos() {
    final expedition = ExpeditionState();
    final currentId = expedition.currentNodeId;
    if (currentId != null && expedition.nodes.containsKey(currentId)) {
      _caravanPos = _getNode3DPosition(expedition.nodes[currentId]!);
    } else {
      // Find first available or completed node
      final available = expedition.nodes.values.where((n) => n.isAvailable || n.isCompleted).toList();
      if (available.isNotEmpty) {
        _caravanPos = _getNode3DPosition(available.first);
      } else {
        _caravanPos = vm.Vector3(0, 0.2, 5.0);
      }
    }
  }

  vm.Vector3 _getNode3DPosition(MapNode node) {
    // Layer goes from 0 (Z = 5.0) to 5 (Z = -6.0)
    final double z = 5.0 - (node.layer * 2.2);
    // Lane goes from 0 (left: -3.5), 1 (mid: 0.0), 2 (right: 3.5)
    double x;
    if (node.type == MapNodeType.bossFestival) {
      x = 0.0;
    } else {
      x = (node.lane - 1) * 3.2;
    }
    final double y = 0.2 + (node.layer * 0.4); // Elevation rising up the mountain
    return vm.Vector3(x, y, z);
  }

  void _onNodeTapped(MapNode node) {
    if (!node.isAvailable || node.isCompleted) {
      if (node.isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu durak zaten tamamlandı.'), duration: Duration(milliseconds: 900)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu durağa şu anki rotadan ulaşılamıyor.'), duration: Duration(milliseconds: 900)),
        );
      }
      return;
    }

    SoundService().playClick();
    setState(() {
      _selectedNodeId = node.id;
    });
  }

  void _startNode(ExpeditionState expedition) {
    if (_selectedNodeId == null) return;
    final node = expedition.nodes[_selectedNodeId];
    if (node == null) return;

    SoundService().playClick();
    final ok = expedition.selectNode(_selectedNodeId!);
    if (!ok) return;

    // Move caravan in 3D
    _caravanPos = _getNode3DPosition(node);

    Widget screen;
    switch (node.type) {
      case MapNodeType.servingDay:
        screen = Caravan3DKitchenScreen(
          isRushHour: false,
          isBossFestival: false,
          targetCustomerCount: 3 + node.layer,
        );
        break;
      case MapNodeType.rushHour:
        screen = Caravan3DKitchenScreen(
          isRushHour: true,
          isBossFestival: false,
          targetCustomerCount: 4 + node.layer,
        );
        break;
      case MapNodeType.mysteryEvent:
        screen = const MysteryEventScreen();
        break;
      case MapNodeType.caravanShop:
        screen = const CaravanShopScreen();
        break;
      case MapNodeType.treasure:
        screen = const TreasureScreen();
        break;
      case MapNodeType.bossFestival:
        screen = Caravan3DKitchenScreen(
          isRushHour: true,
          isBossFestival: true,
          targetCustomerCount: 6,
        );
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      setState(() {
        _selectedNodeId = null;
        _updateCaravanPos();
      });
      _checkRunEnd(expedition);
    });
  }

  void _checkRunEnd(ExpeditionState expedition) {
    if (expedition.isGameOver) {
      GameState().recordExpeditionFinished(
        earnedCoins: expedition.runCoins,
        earnedXp: expedition.currentLayer * 50 + 40,
        won: false,
      );
      Navigator.of(context).pop();
    } else if (expedition.isRunCompleted) {
      GameState().recordExpeditionFinished(
        earnedCoins: expedition.runCoins + 200,
        earnedXp: 350,
        won: true,
      );
      Navigator.of(context).pop();
    }
  }

  List<Mesh3D> _buildMap3DScene(ExpeditionState expedition) {
    final meshes = <Mesh3D>[];

    // 1. 3D Terrain Base
    meshes.add(Mesh3D.createPlane(
      width: 18.0,
      depth: 22.0,
      color: const Color(0xFF1E3A24), // Scenic valley green
      center: vm.Vector3(0, 0, 0),
    ));

    // 2. 3D Mountain Summit at Boss Festival (North)
    final summit = Mesh3D.createBox(
      size: vm.Vector3(14.0, 3.2, 5.0),
      color: const Color(0xFF334155),
      center: vm.Vector3(0, 1.2, -7.0),
    );
    meshes.add(summit);

    // 3. 3D Low-poly Pine Trees along the road
    final rand = Random(1234);
    for (int i = 0; i < 22; i++) {
      final x = (rand.nextDouble() - 0.5) * 16.0;
      final z = (rand.nextDouble() - 0.5) * 18.0;
      // Skip center road path
      if (x.abs() < 1.8 && z.abs() < 7.0) continue;

      final tree = Models3D.createPineTree();
      tree.position = vm.Vector3(x, 0, z);
      tree.scale = vm.Vector3(0.7, 0.7 + rand.nextDouble() * 0.4, 0.7);
      meshes.add(tree);
    }

    // 4. 3D Glowing Node Pedestals
    for (var node in expedition.nodes.values) {
      final pos = _getNode3DPosition(node);
      final isSelected = node.id == _selectedNodeId;
      final isAvailable = node.isAvailable;
      final isCompleted = node.isCompleted;

      Color pedColor;
      if (isCompleted) {
        pedColor = const Color(0xFF15803D); // Green
      } else if (isSelected) {
        pedColor = AppColors.goldenCrema;
      } else if (isAvailable) {
        pedColor = const Color(0xFFF59E0B);
      } else {
        pedColor = const Color(0xFF334155);
      }

      // Pedestal base cylinder
      final ped = Mesh3D.createCylinder(
        radius: node.type == MapNodeType.bossFestival ? 1.0 : 0.65,
        height: 0.35,
        segments: 10,
        color: pedColor,
        center: pos,
      );
      meshes.add(ped);
    }

    // 5. 3D Traveling Caravan Model on current road position
    final caravan = Models3D.createCaravan();
    caravan.position = vm.Vector3(_caravanPos.x, _caravanPos.y + 0.3, _caravanPos.z);
    caravan.scale = vm.Vector3(0.55, 0.55, 0.55);
    caravan.rotation = vm.Vector3(0, -pi / 2, 0); // Facing forward up the trail
    meshes.add(caravan);

    return meshes;
  }

  @override
  Widget build(BuildContext context) {
    final expedition = ExpeditionState();
    final selectedNode = _selectedNodeId != null ? expedition.nodes[_selectedNodeId] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // 3D Canvas with drag to orbit camera
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _camera.orbit(-details.delta.dx * 0.005, details.delta.dy * 0.005);
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _Map3DPainter(
                  renderer: _renderer,
                  camera: _camera,
                  meshes: _buildMap3DScene(expedition),
                ),
              ),
            ),

            // Top Status HUD
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildTopHud(expedition),
            ),

            // Projected 2D Touch Nodes over 3D Pedestals
            ...expedition.nodes.values.map((node) {
              return _buildProjectedNodeTouch(node);
            }),

            // Bottom Selected Node Action Card
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildBottomCard(expedition, selectedNode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud(ExpeditionState expedition) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Row(
            children: List.generate(ExpeditionState.maxHearts, (i) {
              return Text(i < expedition.reputationHearts ? '❤️' : '🖤', style: const TextStyle(fontSize: 14));
            }),
          ),
          InkWell(
            onTap: () => showDialog(context: context, builder: (_) => const DailyMenuDialog()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1B3828),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '📋 Menü (${expedition.activeMenu.length})',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.goldenCrema),
            ),
            child: Text(
              '${expedition.runCoins} 💰',
              style: const TextStyle(color: AppColors.goldenCrema, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectedNodeTouch(MapNode node) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final nodePos3D = _getNode3DPosition(node);
        final screenPos = Renderer3D.worldToScreen(
          worldPos: vm.Vector3(nodePos3D.x, nodePos3D.y + 0.8, nodePos3D.z),
          camera: _camera,
          size: Size(constraints.maxWidth, constraints.maxHeight),
        );
        if (screenPos == null) return const SizedBox();

        final isSelected = node.id == _selectedNodeId;
        final isAvailable = node.isAvailable;
        final isCompleted = node.isCompleted;

        return Positioned(
          left: screenPos.dx - 28,
          top: screenPos.dy - 28,
          width: 56,
          height: 56,
          child: GestureDetector(
            onTap: () => _onNodeTapped(node),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.goldenCrema
                    : (isCompleted
                        ? Colors.green.withValues(alpha: 0.8)
                        : (isAvailable ? AppColors.bgCardLight : Colors.black45)),
                border: Border.all(
                  color: isSelected ? Colors.white : (isAvailable ? AppColors.goldenCrema : Colors.white12),
                  width: isSelected ? 3 : 1.5,
                ),
              ),
              child: Text(
                node.type.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomCard(ExpeditionState expedition, MapNode? selectedNode) {
    if (selectedNode == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: const [
            Text('🚐', style: TextStyle(fontSize: 26)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '3D Haritada sarı ile parlayan bir durağa dokunun ve karavanı sürün!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldenCrema),
      ),
      child: Row(
        children: [
          Text(selectedNode.type.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedNode.type.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.goldenCrema),
                ),
                Text(
                  selectedNode.type.shortDesc,
                  maxLines: 1,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('YOLA ÇIK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            onPressed: () => _startNode(expedition),
          ),
        ],
      ),
    );
  }
}

class _Map3DPainter extends CustomPainter {
  final Renderer3D renderer;
  final Camera3D camera;
  final List<Mesh3D> meshes;

  _Map3DPainter({
    required this.renderer,
    required this.camera,
    required this.meshes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    renderer.renderScene(
      canvas: canvas,
      size: size,
      camera: camera,
      meshes: meshes,
    );
  }

  @override
  bool shouldRepaint(covariant _Map3DPainter oldDelegate) => true;
}
