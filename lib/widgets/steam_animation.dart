import 'dart:math';
import 'package:flutter/material.dart';

class SteamAnimation extends StatefulWidget {
  final double height;
  final double width;
  final Color steamColor;

  const SteamAnimation({
    super.key,
    this.height = 80,
    this.width = 120,
    this.steamColor = const Color(0x66FFFFFF),
  });

  @override
  State<SteamAnimation> createState() => _SteamAnimationState();
}

class _SteamAnimationState extends State<SteamAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SteamPainter(
            progress: _controller.value,
            color: widget.steamColor,
          ),
        );
      },
    );
  }
}

class _SteamPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SteamPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final steamPaths = [
      {'startX': size.width * 0.35, 'speed': 1.0, 'amp': 12.0},
      {'startX': size.width * 0.50, 'speed': 1.2, 'amp': 16.0},
      {'startX': size.width * 0.65, 'speed': 0.9, 'amp': 14.0},
    ];

    for (final steam in steamPaths) {
      final path = Path();
      final startX = steam['startX']!;
      final speed = steam['speed']!;
      final amp = steam['amp']!;

      final localProgress = (progress * speed) % 1.0;
      final currentHeight = size.height * (1.0 - localProgress);

      path.moveTo(startX, size.height);

      for (double y = size.height; y >= currentHeight; y -= 6) {
        final factor = (size.height - y) / size.height;
        final wave = sin((y / 15) + (progress * 2 * pi * speed)) * amp * factor;
        path.lineTo(startX + wave, y);
      }

      final alpha = ((1.0 - localProgress) * 0.6).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: alpha);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) => true;
}
