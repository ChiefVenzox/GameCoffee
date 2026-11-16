import 'dart:async';
import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../utils/app_colors.dart';
import 'sound_service.dart';

class GrinderWidget extends StatefulWidget {
  final BeanType beanType;
  final GrindLevel targetGrind;
  final Function(double accuracy, GrindLevel resultGrind) onGrindCompleted;

  const GrinderWidget({
    super.key,
    required this.beanType,
    required this.targetGrind,
    required this.onGrindCompleted,
  });

  @override
  State<GrinderWidget> createState() => _GrinderWidgetState();
}

class _GrinderWidgetState extends State<GrinderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Timer? _grindTimer;
  double _gaugeProgress = 0.0; // 0.0 to 1.0
  bool _isGrinding = false;
  bool _completed = false;

  // Target ranges for each grind level
  double get _targetMin {
    switch (widget.targetGrind) {
      case GrindLevel.coarse:
        return 0.20;
      case GrindLevel.medium:
        return 0.45;
      case GrindLevel.fine:
        return 0.70;
      case GrindLevel.extraFine:
        return 0.88;
    }
  }

  double get _targetMax {
    switch (widget.targetGrind) {
      case GrindLevel.coarse:
        return 0.40;
      case GrindLevel.medium:
        return 0.65;
      case GrindLevel.fine:
        return 0.85;
      case GrindLevel.extraFine:
        return 0.98;
    }
  }

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _grindTimer?.cancel();
    _spinController.dispose();
    super.dispose();
  }

  void _startGrinding() {
    if (_completed) return;
    setState(() {
      _isGrinding = true;
    });
    _spinController.repeat();

    _grindTimer?.cancel();
    _grindTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      SoundService().playGrinderTick();
      setState(() {
        _gaugeProgress += 0.015;
        if (_gaugeProgress >= 1.0) {
          _gaugeProgress = 1.0;
          _stopGrinding();
        }
      });
    });
  }

  void _stopGrinding() {
    if (!_isGrinding || _completed) return;
    _grindTimer?.cancel();
    _spinController.stop();

    setState(() {
      _isGrinding = false;
      _completed = true;
    });

    // Evaluate result
    final center = (_targetMin + _targetMax) / 2.0;
    final halfWidth = (_targetMax - _targetMin) / 2.0;
    final diff = (_gaugeProgress - center).abs();

    double accuracy;
    if (diff <= halfWidth) {
      accuracy = 1.0 - (diff / halfWidth) * 0.2; // 0.8 to 1.0
    } else {
      accuracy = (1.0 - (diff - halfWidth) * 2.0).clamp(0.2, 0.75);
    }

    GrindLevel resultLevel;
    if (_gaugeProgress < 0.35) {
      resultLevel = GrindLevel.coarse;
    } else if (_gaugeProgress < 0.60) {
      resultLevel = GrindLevel.medium;
    } else if (_gaugeProgress < 0.85) {
      resultLevel = GrindLevel.fine;
    } else {
      resultLevel = GrindLevel.extraFine;
    }

    if (accuracy >= 0.8) {
      SoundService().playSuccess();
    } else {
      SoundService().playError();
    }

    widget.onGrindCompleted(accuracy, resultLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '☕ Çekirdek Öğütme İstasyonu',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenCrema,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warmCoffee,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.targetGrind.displayName.split('(').first.trim(),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grinder Visual & Beans Hopper
          Stack(
            alignment: Alignment.center,
            children: [
              // Hopper Body
              Container(
                width: 140,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF334155),
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                    bottom: Radius.circular(16),
                  ),
                  border: Border.all(color: const Color(0xFF475569), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spinning Burr Icon
                    RotationTransition(
                      turns: _spinController,
                      child: Icon(
                        Icons.settings,
                        size: 52,
                        color: _isGrinding ? AppColors.lightCrema : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.beanType.displayName.split('(').first.trim(),
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.beanType.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Animated vibration overlay
              if (_isGrinding)
                Positioned(
                  bottom: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: widget.beanType.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Gauge Bar with Sweet Spot Zone
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kalın', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    'Hedef: ${_targetMin == 0.88 ? "Pudra (Köz)" : (_targetMin == 0.7 ? "İnce (Espresso)" : (_targetMin == 0.45 ? "Orta (Filtre)" : "Kalın (Soğuk)"))}',
                    style: const TextStyle(fontSize: 12, color: AppColors.goldenCrema, fontWeight: FontWeight.bold),
                  ),
                  const Text('Ekstra İnce', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  // Background Track
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                  ),

                  // Target Sweet Spot Zone Highlight
                  Positioned(
                    left: 280 * _targetMin, // will scale in LayoutBuilder
                    width: 280 * (_targetMax - _targetMin),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.greenAccent, width: 1.5),
                      ),
                    ),
                  ),

                  // Current Progress Needle / Fill
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final currentW = constraints.maxWidth * _gaugeProgress;
                      return Container(
                        height: 24,
                        width: currentW,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldenCrema,
                              _gaugeProgress >= _targetMin && _gaugeProgress <= _targetMax
                                  ? Colors.greenAccent
                                  : AppColors.caramel,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Interactive Push-and-Hold Button
          GestureDetector(
            onTapDown: (_) => _startGrinding(),
            onTapUp: (_) => _stopGrinding(),
            onTapCancel: () => _stopGrinding(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: _isGrinding
                    ? const LinearGradient(
                        colors: [Color(0xFF15803D), Color(0xFF16A34A)],
                      )
                    : AppColors.goldenGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _isGrinding ? Colors.green.withValues(alpha: 0.4) : AppColors.caramel.withValues(alpha: 0.3),
                    blurRadius: _isGrinding ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isGrinding ? Icons.flash_on : Icons.touch_app,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _completed
                        ? 'Öğütme Tamamlandı ✓'
                        : (_isGrinding ? 'ÖĞÜTÜLÜYOR... (Bırak: Durdur)' : 'BASILI TUTARAK ÖĞÜT'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
