import 'package:flutter/material.dart';

/// Görüntüdeki parlama efektli logoyu oluşturan yeniden kullanılabilir bir widget.
///
/// Bu bileşen, üstte siyan bir daire ve altta pembe bir çubuktan oluşur.
/// Elemanlar arasında dikey bir boşluk bulunur ve her birinin kendi parlama efekti vardır.
class YesNoLogo extends StatelessWidget {
  /// Logonun genel boyutunu (genişlik ve yükseklik) belirler.
  final double size;

  /// [YesNoLogo] bileşenini oluşturur.
  ///
  /// [size] parametresi varsayılan olarak 250.0'dır.
  const YesNoLogo({
    Key? key,
    this.size = 250.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Renkleri tanımlayalım
    const Color cyanColor = Color(0xFF00E5FF);
    const Color magentaColor = Color(0xFFFF00FF);

    // Boyutları ana boyuta göre oranlayalım
    final double circleDiameter = size * 0.75;
    final double barHeight = size * 0.1;
    final double barWidth = size * 0.6;
    final double spacing = size * 0.1;

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Gradyanlı ve Parlamalı Daire
          Container(
            width: circleDiameter,
            height: circleDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Daireye yukarıdan aşağıya doğru bir gradyan ekliyoruz
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cyanColor,
                  cyanColor.withOpacity(0.8), // Hafifçe koyulaşan bir ton
                ],
              ),
              boxShadow: [
                // Dairenin etrafındaki ana parlama efekti
                BoxShadow(
                  color: cyanColor.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
                // Alttaki mor parlama etkileşimini taklit etmek için
                BoxShadow(
                  color: Colors.purple.withOpacity(0.4),
                  blurRadius: 50,
                  spreadRadius: -10,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
          ),

          // 2. Daire ve Çubuk Arasındaki Boşluk
          SizedBox(height: spacing),

          // 3. Parlamalı Pembe Çubuk
          Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: magentaColor,
              borderRadius: BorderRadius.circular(barHeight / 2),
              boxShadow: [
                // Çubuğun etrafındaki parlama efekti
                BoxShadow(
                  color: magentaColor.withOpacity(0.7),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}