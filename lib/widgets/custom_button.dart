import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';
import 'package:yes_or_no/core/theme/app_text_styles.dart';

/// Button variant types
enum ButtonVariant {
  primary,   // Cyan
  secondary, // Magenta
  tertiary,  // Gold
}

/// Custom button widget with glassmorphism and glow effects
class CustomButton extends StatefulWidget {
  final ButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget child;
  final bool isEnabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  const CustomButton({
    Key? key,
    required this.variant,
    required this.onPressed,
    required this.child,
    this.isEnabled = true,
    this.width,
    this.height,
    this.padding,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 15.0, end: 25.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (!widget.isEnabled) return Colors.grey.shade700;
    
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primaryCyan;
      case ButtonVariant.secondary:
        return AppColors.secondaryMagenta;
      case ButtonVariant.tertiary:
        return AppColors.tertiaryGold;
    }
  }

  Color _getGlowColor() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primaryCyan;
      case ButtonVariant.secondary:
        return AppColors.secondaryMagenta;
      case ButtonVariant.tertiary:
        return AppColors.tertiaryGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: widget.isEnabled
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor().withOpacity(0.5),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: 2,
                    ),
                  ],
                )
              : null,
          child: ElevatedButton(
            onPressed: widget.isEnabled ? widget.onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getBackgroundColor(),
              foregroundColor: widget.variant == ButtonVariant.tertiary
                  ? Colors.black
                  : Colors.white,
              disabledBackgroundColor: Colors.grey.shade700,
              disabledForegroundColor: Colors.grey.shade500,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(widget.width ?? 48, widget.height ?? 48),
              textStyle: AppTextStyles.buttonMedium,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
