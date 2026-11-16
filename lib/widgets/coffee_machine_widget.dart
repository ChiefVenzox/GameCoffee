import 'dart:async';
import 'package:flutter/material.dart';
import '../models/coffee_recipe.dart';
import '../utils/app_colors.dart';
import 'sound_service.dart';

class CoffeeMachineWidget extends StatefulWidget {
  final BrewMethod brewMethod;
  final Function(double accuracy) onBrewCompleted;

  const CoffeeMachineWidget({
    super.key,
    required this.brewMethod,
    required this.onBrewCompleted,
  });

  @override
  State<CoffeeMachineWidget> createState() => _CoffeeMachineWidgetState();
}

class _CoffeeMachineWidgetState extends State<CoffeeMachineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Timer? _brewTimer;
  double _brewProgress = 0.0; // 0.0 to 1.0
  bool _isBrewing = false;
  bool _tamped = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _brewTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _tampPortafilter() {
    if (_tamped) return;
    SoundService().playTamp();
    setState(() {
      _tamped = true;
    });
  }

  void _startBrewing() {
    if (_isBrewing || _isFinished) return;
    SoundService().playPourTick();
    setState(() {
      _isBrewing = true;
    });

    _brewTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      SoundService().playPourTick();
      setState(() {
        _brewProgress += 0.012;
        if (_brewProgress >= 1.0) {
          _brewProgress = 1.0;
          _stopBrewing();
        }
      });
    });
  }

  void _stopBrewing() {
    if (!_isBrewing || _isFinished) return;
    _brewTimer?.cancel();

    setState(() {
      _isBrewing = false;
      _isFinished = true;
    });

    // Ideal sweet zone is between 0.65 and 0.85
    const sweetMin = 0.65;
    const sweetMax = 0.85;
    double accuracy;
    if (_brewProgress >= sweetMin && _brewProgress <= sweetMax) {
      accuracy = 1.0;
      SoundService().playSuccess();
    } else {
      final diff = _brewProgress < sweetMin ? (sweetMin - _brewProgress) : (_brewProgress - sweetMax);
      accuracy = (1.0 - diff * 2.5).clamp(0.2, 0.85);
      if (accuracy < 0.6) {
        SoundService().playError();
      } else {
        SoundService().playSuccess();
      }
    }

    widget.onBrewCompleted(accuracy);
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.brewMethod) {
      case BrewMethod.espresso:
        return _buildEspressoStation();
      case BrewMethod.turkish:
        return _buildTurkishStation();
      case BrewMethod.pourOver:
        return _buildPourOverStation();
      case BrewMethod.coldBrew:
        return _buildColdBrewStation();
    }
  }

  Widget _buildEspressoStation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡ Profesyonel Espresso Makinesi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenCrema,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _tamped ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _tamped ? Colors.green : Colors.orange),
                ),
                child: Text(
                  _tamped ? 'Portafiltre Sıkıştırıldı ✓' : 'Tamping Bekleniyor',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _tamped ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Machine Group Head Visual
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 9-Bar Gauge
                Positioned(
                  left: 20,
                  top: 15,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F172A),
                      border: Border.all(
                        color: _isBrewing ? Colors.greenAccent : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isBrewing ? '9 BAR' : '0 BAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isBrewing ? Colors.greenAccent : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Portafilter & Spout
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.coffee_maker,
                      size: 48,
                      color: _tamped ? AppColors.goldenCrema : const Color(0xFF94A3B8),
                    ),
                    if (_isBrewing)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 3, height: 20, color: AppColors.goldenCrema),
                          const SizedBox(width: 8),
                          Container(width: 3, height: 20, color: AppColors.goldenCrema),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress gauge
          if (_tamped) ...[
            _buildExtractionGauge('Espresso Ekstraksiyonu (Altın Crema Bölgesinde Durdur)'),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          if (!_tamped)
            ElevatedButton.icon(
              onPressed: _tampPortafilter,
              icon: const Icon(Icons.compress),
              label: const Text('PORTAFİLTREYİ SIKIŞTIR (TAMPING)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else if (!_isBrewing && !_isFinished)
            ElevatedButton.icon(
              onPressed: _startBrewing,
              icon: const Icon(Icons.play_arrow),
              label: const Text('EKSTRAKSİYONU BAŞLAT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else if (_isBrewing)
            ElevatedButton.icon(
              onPressed: _stopBrewing,
              icon: const Icon(Icons.stop),
              label: const Text('ŞİMDİ DURDUR! (KREMA ZİRVESİ)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Espresso Başarıyla Çekildi! ✓',
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTurkishStation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '🔥 Közde Bakır Cezve İstasyonu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.copperCezve,
                ),
              ),
              Text('Geleneksel Pişirme', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          // Hot Sand / Ember Visual
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFF78350F), Color(0xFF451A03)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: _isBrewing ? 0.6 : 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cezve icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🫖',
                      style: TextStyle(
                        fontSize: 44,
                        shadows: [
                          Shadow(
                            color: Colors.orangeAccent,
                            blurRadius: _isBrewing ? 20 : 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isBrewing ? 'Köpük kabarıyor...' : 'Köz Hazır',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildExtractionGauge('Köpük Seviyesi (Taşmadan önce yeşil alanda ateşten al!)'),
          const SizedBox(height: 16),

          if (!_isBrewing && !_isFinished)
            ElevatedButton.icon(
              onPressed: _startBrewing,
              icon: const Icon(Icons.fireplace),
              label: const Text('CEZVEYİ KÖZE BIRAK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.copperCezve,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else if (_isBrewing)
            ElevatedButton.icon(
              onPressed: _stopBrewing,
              icon: const Icon(Icons.pan_tool),
              label: const Text('KÖZDEN AL! (KÖPÜK TAŞMASIN!)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Bol Köpüklü Türk Kahvesi Pişti! ✓',
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPourOverStation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '⏳ V60 Manuel Filtre İstasyonu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.goldenCrema,
                ),
              ),
              Text('Spiral Akış', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          // Gooseneck kettle visual
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('☕ Dripper & Filtre', style: TextStyle(fontSize: 28)),
                SizedBox(height: 4),
                Text('92°C Su ile Ön Demleme (Blooming)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildExtractionGauge('Süzülme & Çözünme Dengesi'),
          const SizedBox(height: 16),

          if (!_isBrewing && !_isFinished)
            ElevatedButton.icon(
              onPressed: _startBrewing,
              icon: const Icon(Icons.water_drop),
              label: const Text('SPİRAL SU DÖKÜŞÜNE BAŞLA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.caramel,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else if (_isBrewing)
            ElevatedButton.icon(
              onPressed: _stopBrewing,
              icon: const Icon(Icons.check_circle),
              label: const Text('DÖKÜŞÜ TAMAMLA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Filtre Kahve Kusursuz Süzüldü! ✓',
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColdBrewStation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '🧊 Soğuk Demleme & Buz İstasyonu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              Text('Buzlu Kahve', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF075985), Color(0xFF0C4A6E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('🧊 Buz Küpleri Eklendi', style: TextStyle(fontSize: 24)),
                SizedBox(height: 4),
                Text('Soğuk Süt & Espresso Katmanı', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildExtractionGauge('Soğuk Kahve & Buz Oranı'),
          const SizedBox(height: 16),

          if (!_isBrewing && !_isFinished)
            ElevatedButton.icon(
              onPressed: _startBrewing,
              icon: const Icon(Icons.ac_unit),
              label: const Text('KAHVEYİ BUZUN ÜZERİNE DÖK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else if (_isBrewing)
            ElevatedButton.icon(
              onPressed: _stopBrewing,
              icon: const Icon(Icons.check),
              label: const Text('DÖKÜŞÜ TAMAMLA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 48),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Ferahlatıcı Buzlu Kahve Hazır! ✓',
                  style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtractionGauge(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
            Text(
              '${(_brewProgress * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldenCrema),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155)),
              ),
            ),
            // Ideal Sweet Zone
            LayoutBuilder(
              builder: (context, constraints) {
                return Positioned(
                  left: constraints.maxWidth * 0.65,
                  width: constraints.maxWidth * 0.20,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.greenAccent, width: 1.5),
                    ),
                  ),
                );
              },
            ),
            // Current Fill
            LayoutBuilder(
              builder: (context, constraints) {
                final isSweet = _brewProgress >= 0.65 && _brewProgress <= 0.85;
                return Container(
                  height: 20,
                  width: constraints.maxWidth * _brewProgress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.caramel,
                        isSweet ? Colors.greenAccent : (_brewProgress > 0.85 ? Colors.redAccent : AppColors.goldenCrema),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
