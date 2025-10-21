import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Pembe bir çubuğun etrafında dönen ve titreşen (pulse) siyan bir daireden oluşan
/// özel bir yükleme göstergesi (loading indicator) widget'ı.
class SpinningLogoLoader extends StatefulWidget {
  /// Yükleme göstergesinin genel boyutunu (genişlik ve yükseklik) belirler.
  final double size;

  /// [SpinningLogoLoader] bileşenini oluşturur.
  ///
  /// [size] parametresi varsayılan olarak 80.0'dır.
  const SpinningLogoLoader({
    Key? key,
    this.size = 80.0,
  }) : super(key: key);

  @override
  State<SpinningLogoLoader> createState() => _SpinningLogoLoaderState();
}

// TickerProviderStateMixin, animasyonların düzgün çalışması için gereklidir.
class _SpinningLogoLoaderState extends State<SpinningLogoLoader>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Dönme animasyonunu kontrol etmek için controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(); // Animasyonu sonsuz döngüde tekrarla

    // Titreşim (pulse) animasyonunu kontrol etmek için controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true); // Animasyonu ileri-geri tekrarla

    // Titreşim animasyonunun ölçek değerlerini belirle
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // Controller'ları temizleyerek hafıza sızıntısını önle
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Renkleri tanımlayalım
    const Color cyanColor = Color(0xFF00E5FF);
    const Color magentaColor = Color(0xFFFF00FF);
    
    // Boyutları ana boyuta göre oranlayalım
    final double barWidth = widget.size * 0.4;
    final double barHeight = widget.size * 0.1;
    final double circleDiameter = widget.size * 0.2;
    // Dairenin döneceği yörüngenin çapı
    final double orbitDiameter = widget.size * 0.7;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Merkezde duran Pembe Çubuk
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: magentaColor,
              borderRadius: BorderRadius.circular(barHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: magentaColor.withOpacity(0.7),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          
          // 2. Dönen ve Titreşen Siyan Daire
          // RotationTransition, controller'a bağlı olarak çocuğunu döndürür.
          RotationTransition(
            turns: _rotationController,
            child: SizedBox(
              width: orbitDiameter,
              height: orbitDiameter,
              // Stack, daireyi yörüngenin kenarına konumlandırmamızı sağlar
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // ScaleTransition, daireye büyüme-küçülme efekti verir.
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: circleDiameter,
                      height: circleDiameter,
                      decoration: BoxDecoration(
                        color: cyanColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cyanColor.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
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