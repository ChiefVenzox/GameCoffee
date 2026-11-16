import 'dart:math';
import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../utils/app_colors.dart';

class CoffeeCupWidget extends StatelessWidget {
  final CupType cupType;
  final double fillLevel; // 0.0 to 1.0
  final Color coffeeColor;
  final bool hasMilk;
  final FoamLevel foamLevel;
  final ToppingType topping;
  final bool hasIce;
  final List<Offset>? latteArtPoints;
  final double width;
  final double height;

  const CoffeeCupWidget({
    super.key,
    required this.cupType,
    required this.fillLevel,
    this.coffeeColor = AppColors.deepCoffee,
    this.hasMilk = false,
    this.foamLevel = FoamLevel.none,
    this.topping = ToppingType.none,
    this.hasIce = false,
    this.latteArtPoints,
    this.width = 180,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CoffeeCupPainter(
        cupType: cupType,
        fillLevel: fillLevel,
        coffeeColor: coffeeColor,
        hasMilk: hasMilk,
        foamLevel: foamLevel,
        topping: topping,
        hasIce: hasIce,
        latteArtPoints: latteArtPoints,
      ),
    );
  }
}

class _CoffeeCupPainter extends CustomPainter {
  final CupType cupType;
  final double fillLevel;
  final Color coffeeColor;
  final bool hasMilk;
  final FoamLevel foamLevel;
  final ToppingType topping;
  final bool hasIce;
  final List<Offset>? latteArtPoints;

  _CoffeeCupPainter({
    required this.cupType,
    required this.fillLevel,
    required this.coffeeColor,
    required this.hasMilk,
    required this.foamLevel,
    required this.topping,
    required this.hasIce,
    required this.latteArtPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (cupType) {
      case CupType.espressoCup:
        _drawEspressoCup(canvas, size);
        break;
      case CupType.turkishCup:
        _drawTurkishCup(canvas, size);
        break;
      case CupType.latteGlass:
        _drawLatteGlass(canvas, size);
        break;
      case CupType.takeawayCup:
        _drawTakeawayCup(canvas, size);
        break;
      case CupType.icedTallGlass:
        _drawIcedTallGlass(canvas, size);
        break;
    }
  }

  void _drawEspressoCup(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Cup dimensions
    final cupLeft = w * 0.25;
    final cupRight = w * 0.75;
    final cupTop = h * 0.35;
    final cupBottom = h * 0.82;
    final cupWidth = cupRight - cupLeft;
    final cupHeight = cupBottom - cupTop;

    // Saucer (Tabak)
    final saucerPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, cupBottom + 12),
        width: cupWidth * 1.5,
        height: 18,
      ),
      saucerPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, cupBottom + 12),
        width: cupWidth * 1.5,
        height: 18,
      ),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Cup Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final handlePath = Path()
      ..moveTo(cupRight - 4, cupTop + cupHeight * 0.25)
      ..cubicTo(
        cupRight + 32, cupTop + cupHeight * 0.25,
        cupRight + 32, cupBottom - cupHeight * 0.25,
        cupRight - 4, cupBottom - cupHeight * 0.25,
      );
    canvas.drawPath(handlePath, handlePaint);

    // Liquid clip path
    final cupPath = Path();
    cupPath.moveTo(cupLeft, cupTop);
    cupPath.lineTo(cupLeft + 12, cupBottom);
    cupPath.quadraticBezierTo(w * 0.5, cupBottom + 8, cupRight - 12, cupBottom);
    cupPath.lineTo(cupRight, cupTop);
    cupPath.close();

    // Draw Liquid
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);

      final liquidTop = cupBottom - (cupHeight * fillLevel);
      final liquidRect = Rect.fromLTRB(cupLeft, liquidTop, cupRight, cupBottom + 10);

      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hasMilk ? AppColors.milkCoffee : AppColors.goldenCrema,
            coffeeColor,
            AppColors.darkEspresso,
          ],
        ).createShader(liquidRect);

      canvas.drawRect(liquidRect, liquidPaint);

      // Foam layer
      _drawFoamAndToppings(canvas, cupLeft + 4, cupRight - 4, liquidTop, w, h);

      canvas.restore();
    }

    // Cup outer body (porcelain look)
    final cupBodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFFE2E8F0), Color(0xFFFFFFFF), Color(0xFFCBD5E1)],
      ).createShader(Rect.fromLTRB(cupLeft, cupTop, cupRight, cupBottom))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawPath(cupPath, cupBodyPaint);

    // Rim highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, cupTop),
        width: cupWidth,
        height: 16,
      ),
      Paint()
        ..color = const Color(0xFFF8FAFC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawTurkishCup(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cupLeft = w * 0.28;
    final cupRight = w * 0.72;
    final cupTop = h * 0.32;
    final cupBottom = h * 0.82;
    final cupWidth = cupRight - cupLeft;
    final cupHeight = cupBottom - cupTop;

    // Ottoman Copper/Gold Saucer
    final saucerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.copperCezve, AppColors.goldenCrema, AppColors.copperCezve],
      ).createShader(Rect.fromLTWH(w * 0.1, cupBottom, w * 0.8, 20));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, cupBottom + 10),
        width: cupWidth * 1.6,
        height: 20,
      ),
      saucerPaint,
    );

    // Ornate Handle (Curved bronze handle)
    final handlePaint = Paint()
      ..color = AppColors.copperCezve
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final handlePath = Path()
      ..moveTo(cupRight - 2, cupTop + 20)
      ..cubicTo(cupRight + 34, cupTop + 10, cupRight + 34, cupBottom - 15, cupRight - 2, cupBottom - 15);
    canvas.drawPath(handlePath, handlePaint);

    // Cup Path with slight hourglass / Ottoman tulip curve
    final cupPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..quadraticBezierTo(cupLeft + 8, cupTop + cupHeight * 0.5, cupLeft + 4, cupBottom)
      ..quadraticBezierTo(w * 0.5, cupBottom + 6, cupRight - 4, cupBottom)
      ..quadraticBezierTo(cupRight - 8, cupTop + cupHeight * 0.5, cupRight, cupTop)
      ..close();

    // Draw Liquid
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);

      final liquidTop = cupBottom - (cupHeight * fillLevel);
      final liquidRect = Rect.fromLTRB(cupLeft, liquidTop, cupRight, cupBottom + 10);

      // Turkish coffee has dark rich body with thick golden foam on top
      final liquidPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF8B5A2B), // Foam
            Color(0xFF381F12), // Coffee
            Color(0xFF1E120A), // Telve (grounds) at bottom
          ],
        ).createShader(liquidRect);
      canvas.drawRect(liquidRect, liquidPaint);

      // Thick frothy foam bubbles for Turkish Coffee
      final foamPaint = Paint()..color = const Color(0xFFC48B47);
      for (int i = 0; i < 8; i++) {
        final bx = cupLeft + 10 + (i * 12.0);
        final by = liquidTop + (sin(i * 1.5) * 3);
        canvas.drawCircle(Offset(bx, by), 4, foamPaint);
      }

      canvas.restore();
    }

    // White Porcelain Cup with Golden Trim
    final cupPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Colors.white, Color(0xFFCBD5E1)],
      ).createShader(Rect.fromLTRB(cupLeft, cupTop, cupRight, cupBottom))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(cupPath, cupPaint);

    // Golden decorative rim band
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, cupTop + 2), width: cupWidth, height: 14),
      Paint()
        ..color = AppColors.goldenCrema
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  void _drawLatteGlass(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cupLeft = w * 0.22;
    final cupRight = w * 0.78;
    final cupTop = h * 0.25;
    final cupBottom = h * 0.85;
    final cupHeight = cupBottom - cupTop;

    // Handle
    final handlePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final handlePath = Path()
      ..moveTo(cupRight - 4, cupTop + cupHeight * 0.2)
      ..cubicTo(
        cupRight + 38, cupTop + cupHeight * 0.2,
        cupRight + 38, cupBottom - cupHeight * 0.2,
        cupRight - 4, cupBottom - cupHeight * 0.2,
      );
    canvas.drawPath(handlePath, handlePaint);

    // Cup contour
    final cupPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..lineTo(cupLeft + 15, cupBottom)
      ..quadraticBezierTo(w * 0.5, cupBottom + 8, cupRight - 15, cupBottom)
      ..lineTo(cupRight, cupTop)
      ..close();

    // Liquid with Layers
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);

      final liquidTop = cupBottom - (cupHeight * fillLevel);
      final liquidRect = Rect.fromLTRB(cupLeft, liquidTop, cupRight, cupBottom + 10);

      // Latte layers: Milk on bottom, espresso in middle, foam on top!
      final gradientColors = hasMilk
          ? [
              AppColors.milkFoam,
              AppColors.caramel,
              AppColors.deepCoffee,
              AppColors.milkCoffee,
              AppColors.warmMilk,
            ]
          : [
              AppColors.goldenCrema,
              coffeeColor,
              AppColors.darkEspresso,
            ];

      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ).createShader(liquidRect);
      canvas.drawRect(liquidRect, liquidPaint);

      // Foam and Art
      _drawFoamAndToppings(canvas, cupLeft + 8, cupRight - 8, liquidTop, w, h);

      canvas.restore();
    }

    // Ceramic border
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Colors.white, Color(0xFF94A3B8)],
      ).createShader(Rect.fromLTRB(cupLeft, cupTop, cupRight, cupBottom))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawPath(cupPath, bodyPaint);
  }

  void _drawTakeawayCup(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cupLeft = w * 0.26;
    final cupRight = w * 0.74;
    final cupTop = h * 0.22;
    final cupBottom = h * 0.88;
    final cupHeight = cupBottom - cupTop;

    // Cup Path
    final cupPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..lineTo(cupLeft + 20, cupBottom)
      ..quadraticBezierTo(w * 0.5, cupBottom + 4, cupRight - 20, cupBottom)
      ..lineTo(cupRight, cupTop)
      ..close();

    // Paper Cup background
    final cupBgPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cupPath, cupBgPaint);

    // Liquid
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(cupPath);

      final liquidTop = cupBottom - (cupHeight * fillLevel);
      final liquidRect = Rect.fromLTRB(cupLeft, liquidTop, cupRight, cupBottom + 10);

      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hasMilk ? AppColors.milkFoam : AppColors.goldenCrema,
            hasMilk ? AppColors.milkCoffee : coffeeColor,
            AppColors.darkEspresso,
          ],
        ).createShader(liquidRect);
      canvas.drawRect(liquidRect, liquidPaint);

      _drawFoamAndToppings(canvas, cupLeft + 12, cupRight - 12, liquidTop, w, h);
      canvas.restore();
    }

    // Cardboard Sleeve (Kraft sleeve around cup)
    final sleeveTop = cupTop + cupHeight * 0.35;
    final sleeveBottom = cupTop + cupHeight * 0.65;
    final sleevePath = Path()
      ..moveTo(cupLeft + 7, sleeveTop)
      ..lineTo(cupLeft + 13, sleeveBottom)
      ..lineTo(cupRight - 13, sleeveBottom)
      ..lineTo(cupRight - 7, sleeveTop)
      ..close();
    final sleevePaint = Paint()..color = const Color(0xFFC49A6C);
    canvas.drawPath(sleevePath, sleevePaint);

    // Coffee Logo on sleeve
    final logoPaint = Paint()
      ..color = const Color(0xFF4A2810)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w * 0.5, (sleeveTop + sleeveBottom) / 2), 16, logoPaint);

    // Cup outline
    canvas.drawPath(
      cupPath,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  void _drawIcedTallGlass(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final cupLeft = w * 0.28;
    final cupRight = w * 0.72;
    final cupTop = h * 0.18;
    final cupBottom = h * 0.88;
    final cupHeight = cupBottom - cupTop;

    // Clear tall glass
    final glassPath = Path()
      ..moveTo(cupLeft, cupTop)
      ..lineTo(cupLeft + 12, cupBottom)
      ..quadraticBezierTo(w * 0.5, cupBottom + 6, cupRight - 12, cupBottom)
      ..lineTo(cupRight, cupTop)
      ..close();

    // Liquid
    if (fillLevel > 0) {
      canvas.save();
      canvas.clipPath(glassPath);

      final liquidTop = cupBottom - (cupHeight * fillLevel);
      final liquidRect = Rect.fromLTRB(cupLeft, liquidTop, cupRight, cupBottom + 10);

      final liquidPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            hasMilk ? AppColors.milkFoam : AppColors.caramel,
            coffeeColor,
            AppColors.darkEspresso,
          ],
        ).createShader(liquidRect);
      canvas.drawRect(liquidRect, liquidPaint);

      // Floating Ice Cubes!
      final icePaint = Paint()
        ..color = const Color(0x99E0F2FE)
        ..style = PaintingStyle.fill;
      final iceBorder = Paint()
        ..color = const Color(0xCCBAE6FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final icePositions = [
        Offset(w * 0.42, liquidTop + 25),
        Offset(w * 0.58, liquidTop + 45),
        Offset(w * 0.46, liquidTop + 75),
      ];

      for (final pos in icePositions) {
        if (pos.dy < cupBottom - 10) {
          final r = RRect.fromRectAndRadius(
            Rect.fromCenter(center: pos, width: 28, height: 24),
            const Radius.circular(5),
          );
          canvas.drawRRect(r, icePaint);
          canvas.drawRRect(r, iceBorder);
        }
      }

      _drawFoamAndToppings(canvas, cupLeft + 8, cupRight - 8, liquidTop, w, h);
      canvas.restore();
    }

    // Glass reflection highlights
    final glassBorder = Paint()
      ..color = const Color(0x8894A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(glassPath, glassBorder);

    // Glass sheen line
    final sheenPath = Path()
      ..moveTo(cupLeft + 6, cupTop + 10)
      ..lineTo(cupLeft + 15, cupBottom - 10);
    canvas.drawPath(
      sheenPath,
      Paint()
        ..color = const Color(0x55FFFFFF)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawFoamAndToppings(
    Canvas canvas,
    double left,
    double right,
    double top,
    double w,
    double h,
  ) {
    final width = right - left;

    // Draw Foam layer
    if (foamLevel != FoamLevel.none) {
      final foamHeight = foamLevel == FoamLevel.dense ? 26.0 : (foamLevel == FoamLevel.medium ? 18.0 : 10.0);
      final foamRect = Rect.fromLTRB(left, top, right, top + foamHeight);
      final foamPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.warmMilk, AppColors.milkFoam, AppColors.goldenCrema],
        ).createShader(foamRect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(foamRect, const Radius.circular(8)),
        foamPaint,
      );
    }

    // Latte Art (if points exist)
    if (latteArtPoints != null && latteArtPoints!.isNotEmpty) {
      final artPaint = Paint()
        ..color = AppColors.warmMilk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < latteArtPoints!.length - 1; i++) {
        final p1 = latteArtPoints![i];
        final p2 = latteArtPoints![i + 1];
        if (p1 != Offset.zero && p2 != Offset.zero) {
          canvas.drawLine(
            Offset(left + p1.dx * width, top + (p1.dy * 24)),
            Offset(left + p2.dx * width, top + (p2.dy * 24)),
            artPaint,
          );
        }
      }
    }

    // Toppings
    if (topping == ToppingType.cocoa || topping == ToppingType.cinnamon) {
      final dustColor = topping == ToppingType.cocoa ? const Color(0xFF4A2810) : const Color(0xFFC86432);
      final dustPaint = Paint()..color = dustColor;
      final rng = Random(42);
      for (int i = 0; i < 30; i++) {
        final dx = left + 10 + rng.nextDouble() * (width - 20);
        final dy = top + 2 + rng.nextDouble() * 12;
        canvas.drawCircle(Offset(dx, dy), 1.5, dustPaint);
      }
    } else if (topping == ToppingType.chocolateDrizzle) {
      final saucePaint = Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      final saucePath = Path()..moveTo(left + 15, top + 6);
      for (double x = left + 15; x < right - 15; x += 16) {
        saucePath.relativeQuadraticBezierTo(8, 8, 16, 0);
      }
      canvas.drawPath(saucePath, saucePaint);
    } else if (topping == ToppingType.whippedCream) {
      final creamPaint = Paint()..color = const Color(0xFFFFFBEB);
      canvas.drawCircle(Offset(w * 0.5, top - 6), 18, creamPaint);
      canvas.drawCircle(Offset(w * 0.44, top - 2), 14, creamPaint);
      canvas.drawCircle(Offset(w * 0.56, top - 2), 14, creamPaint);
      canvas.drawCircle(Offset(w * 0.5, top - 18), 10, creamPaint);
    } else if (topping == ToppingType.marshmallows) {
      final colors = [const Color(0xFFFECDD3), const Color(0xFFFEF08A), const Color(0xFFE0E7FF)];
      for (int i = 0; i < 5; i++) {
        final mPaint = Paint()..color = colors[i % colors.length];
        final mx = left + 20 + (i * 18.0);
        final my = top + 4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(mx, my, 12, 10), const Radius.circular(3)),
          mPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CoffeeCupPainter oldDelegate) => true;
}
