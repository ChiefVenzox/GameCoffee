import 'dart:math';
import 'package:flutter/material.dart';
import '../models/expedition_model.dart';
import '../utils/app_colors.dart';

class CaravanMapPainter extends CustomPainter {
  final Map<String, MapNode> nodes;
  final String? currentNodeId;
  final double pulseValue; // 0.0 to 1.0 for pulsating available nodes
  final Color skyColor;
  final Color groundColor;

  CaravanMapPainter({
    required this.nodes,
    this.currentNodeId,
    required this.pulseValue,
    required this.skyColor,
    required this.groundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw atmospheric background gradient
    final bgRect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          skyColor,
          groundColor,
          AppColors.bgDark,
        ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Draw ambient roadside scenery (pine trees, hills, campfires)
    _drawScenery(canvas, size);

    // Calculate node pixel coordinates
    // We scroll vertically: Layer 0 (Start) is at bottom, Layer 5 (Festival) is at top.
    final Map<String, Offset> nodePositions = {};
    const double paddingX = 40.0;
    const double paddingY = 80.0;
    final double availableWidth = size.width - (paddingX * 2);
    final double availableHeight = size.height - (paddingY * 2);

    for (var node in nodes.values) {
      // Y goes from bottom (layer 0) to top (layer 5)
      final double progressY = node.layer / (ExpeditionState.totalLayers - 1);
      final double posY = size.height - paddingY - (progressY * availableHeight);

      // X position based on lane (0: left, 1: mid, 2: right)
      double posX;
      if (node.type == MapNodeType.bossFestival) {
        posX = size.width / 2; // Always centered
      } else {
        posX = paddingX + (node.lane / 2.0) * availableWidth;
      }

      nodePositions[node.id] = Offset(posX, posY);
    }

    // 3. Draw connecting paths / roads
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (var node in nodes.values) {
      final startPos = nodePositions[node.id];
      if (startPos == null) continue;

      for (var nextId in node.nextNodeIds) {
        final endPos = nodePositions[nextId];
        if (endPos == null) continue;

        final isPathTraversed = node.isCompleted &&
            (nodes[nextId]?.isCompleted == true || nodes[nextId]?.id == currentNodeId);

        if (isPathTraversed) {
          pathPaint.color = AppColors.goldenCrema;
          pathPaint.strokeWidth = 4.0;
        } else if (nodes[nextId]?.isAvailable == true) {
          pathPaint.color = AppColors.lightCrema.withValues(alpha: 0.7);
          pathPaint.strokeWidth = 3.0;
        } else {
          pathPaint.color = Colors.white.withValues(alpha: 0.18);
          pathPaint.strokeWidth = 2.0;
        }

        // Draw curved bezier path for natural winding road feel
        final path = Path();
        path.moveTo(startPos.dx, startPos.dy);
        final controlPoint1 = Offset(startPos.dx, (startPos.dy + endPos.dy) / 2);
        final controlPoint2 = Offset(endPos.dx, (startPos.dy + endPos.dy) / 2);
        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          endPos.dx,
          endPos.dy,
        );

        canvas.drawPath(path, pathPaint);
      }
    }

    // 4. Draw Nodes
    for (var node in nodes.values) {
      final pos = nodePositions[node.id];
      if (pos == null) continue;

      final isCurrent = node.id == currentNodeId;
      final isAvailable = node.isAvailable;
      final isCompleted = node.isCompleted;

      // Base radius
      final double radius = node.type == MapNodeType.bossFestival ? 34.0 : 25.0;

      // Pulsing effect for available nodes
      if (isAvailable && !isCompleted) {
        final pulseRadius = radius + (pulseValue * 8);
        final pulsePaint = Paint()
          ..color = AppColors.goldenCrema.withValues(alpha: 0.35 * (1.0 - pulseValue))
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, pulseRadius, pulsePaint);
      }

      // Outer glow for active node
      if (isCurrent) {
        final glowPaint = Paint()
          ..color = Colors.amberAccent.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(pos, radius + 4, glowPaint);
      }

      // Node background circle
      Color nodeColor;
      if (isCompleted) {
        nodeColor = const Color(0xFF2E4032);
      } else if (isAvailable || isCurrent) {
        nodeColor = AppColors.bgCardLight;
      } else {
        nodeColor = const Color(0xFF1F1713).withValues(alpha: 0.85);
      }

      final circlePaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius, circlePaint);

      // Node border
      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrent || isAvailable ? 3.0 : 1.5
        ..color = isCompleted
            ? Colors.greenAccent
            : (isCurrent
                ? Colors.amberAccent
                : (isAvailable
                    ? AppColors.goldenCrema
                    : Colors.white.withValues(alpha: 0.2)));
      canvas.drawCircle(pos, radius, borderPaint);

      // Draw checkmark badge if completed
      if (isCompleted) {
        final badgePaint = Paint()..color = Colors.green;
        canvas.drawCircle(Offset(pos.dx + radius - 4, pos.dy - radius + 4), 8, badgePaint);
      }
    }
  }

  void _drawScenery(Canvas canvas, Size size) {
    final treePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final rand = Random(42); // deterministic seed so trees stay stable
    for (int i = 0; i < 18; i++) {
      final tx = rand.nextDouble() * size.width;
      final ty = rand.nextDouble() * size.height;

      // Draw simple cozy pine tree silhouette
      final treePath = Path();
      treePath.moveTo(tx, ty - 16);
      treePath.lineTo(tx + 10, ty);
      treePath.lineTo(tx + 6, ty);
      treePath.lineTo(tx + 12, ty + 12);
      treePath.lineTo(tx - 12, ty + 12);
      treePath.lineTo(tx - 6, ty);
      treePath.lineTo(tx - 10, ty);
      treePath.close();

      canvas.drawPath(treePath, treePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CaravanMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.currentNodeId != currentNodeId ||
        oldDelegate.nodes != nodes;
  }
}
