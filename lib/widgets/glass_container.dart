import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphism container widget for panels and cards
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final double blurAmount;

  const GlassContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.width,
    this.height,
    this.blurAmount = 15.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassPanelBase,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.borderGlass,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
