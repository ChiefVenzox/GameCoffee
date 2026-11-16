import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/sound_service.dart';

class LatteArtScreen extends StatefulWidget {
  final VoidCallback onFinished;
  final Function(List<Offset> points) onSaveArt;

  const LatteArtScreen({
    super.key,
    required this.onFinished,
    required this.onSaveArt,
  });

  @override
  State<LatteArtScreen> createState() => _LatteArtScreenState();
}

class _LatteArtScreenState extends State<LatteArtScreen> {
  final List<Offset> _points = [];
  String _selectedTemplate = 'free';

  void _applyTemplate(String template) {
    setState(() {
      _selectedTemplate = template;
      _points.clear();

      if (template == 'heart') {
        // Pre-generate heart curve points normalized (0.0 to 1.0)
        _points.addAll([
          const Offset(0.50, 0.20),
          const Offset(0.35, 0.10),
          const Offset(0.20, 0.25),
          const Offset(0.25, 0.50),
          const Offset(0.50, 0.85),
          const Offset(0.75, 0.50),
          const Offset(0.80, 0.25),
          const Offset(0.65, 0.10),
          const Offset(0.50, 0.20),
        ]);
      } else if (template == 'tulip') {
        // Tulip layers
        _points.addAll([
          const Offset(0.50, 0.20),
          const Offset(0.30, 0.35),
          const Offset(0.70, 0.35),
          const Offset(0.50, 0.45),
          const Offset(0.35, 0.60),
          const Offset(0.65, 0.60),
          const Offset(0.50, 0.85),
        ]);
      } else if (template == 'rosetta') {
        // Rosetta zigzag stem
        for (double y = 0.85; y >= 0.20; y -= 0.08) {
          _points.add(Offset(0.50 + ((y % 0.16 == 0 ? 0.2 : -0.2)), y));
        }
        _points.add(const Offset(0.50, 0.15));
      }
    });
    SoundService().playSuccess();
  }

  void _clearCanvas() {
    setState(() {
      _points.clear();
      _selectedTemplate = 'free';
    });
    SoundService().playClick();
  }

  void _finish() {
    widget.onSaveArt(_points);
    SoundService().playSuccess();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('🎨 Latte Art Sanat Stüdyosu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Temizle',
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Parmağını fincan üzerinde kaydırarak süt köpüğü ile desen çiz veya şablon seç!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),

            // Template Selector Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTemplateChip('free', '✏️ Serbest Çizim'),
                  const SizedBox(width: 8),
                  _buildTemplateChip('heart', '❤️ Kalp (Heart)'),
                  const SizedBox(width: 8),
                  _buildTemplateChip('tulip', '🌷 Lale (Tulip)'),
                  const SizedBox(width: 8),
                  _buildTemplateChip('rosetta', '🌿 Rosetta (Fern)'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Circular Latte Cup Canvas
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldenCrema.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ceramic Rim Outer
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 14),
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFF4A2810),
                                Color(0xFF2E1A0F),
                                Color(0xFF160E08),
                              ],
                            ),
                          ),
                        ),

                        // Touch Drawing Area
                        GestureDetector(
                          onPanUpdate: (details) {
                            final RenderBox renderBox = context.findRenderObject() as RenderBox;
                            final localPos = renderBox.globalToLocal(details.globalPosition);

                            // Normalize coordinates within 0.0 to 1.0
                            final normX = (localPos.dx / renderBox.size.width).clamp(0.1, 0.9);
                            final normY = (localPos.dy / renderBox.size.height).clamp(0.1, 0.9);

                            SoundService().playFoamTick();
                            setState(() {
                              _points.add(Offset(normX, normY));
                            });
                          },
                          onPanEnd: (_) {
                            _points.add(Offset.zero); // break line
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _LatteArtPainter(points: _points),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Finish Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _finish,
                icon: const Icon(Icons.check_circle_outline, size: 24),
                label: const Text('LATTE ART TAMAMLANDI - SERVİS ET'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldenCrema,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String id, String label) {
    final isSelected = _selectedTemplate == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyTemplate(id),
      selectedColor: AppColors.goldenCrema,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppColors.bgCard,
    );
  }
}

class _LatteArtPainter extends CustomPainter {
  final List<Offset> points;

  _LatteArtPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    // Foam background shimmer
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.44;

    final cremaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.goldenCrema.withValues(alpha: 0.8),
          AppColors.caramel,
          AppColors.warmCoffee,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, cremaPaint);

    // Draw user drawn / template white milk foam strokes
    final milkPaint = Paint()
      ..color = AppColors.warmMilk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = AppColors.milkFoam.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        final p1 = Offset(points[i].dx * size.width, points[i].dy * size.height);
        final p2 = Offset(points[i + 1].dx * size.width, points[i + 1].dy * size.height);
        canvas.drawLine(p1, p2, glowPaint);
        canvas.drawLine(p1, p2, milkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LatteArtPainter oldDelegate) => true;
}
