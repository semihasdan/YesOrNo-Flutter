import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';
import 'package:yes_or_no/core/theme/app_text_styles.dart';

/// Circular countdown timer widget with color transitions
class CircularTimerWidget extends StatefulWidget {
  final int seconds;
  final int maxSeconds;
  final VoidCallback? onTimerEnd;

  const CircularTimerWidget({
    Key? key,
    required this.seconds,
    this.maxSeconds = 10,
    this.onTimerEnd,
  }) : super(key: key);

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 15.0, end: 30.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (widget.seconds <= 3) {
      return AppColors.timerRed;
    } else if (widget.seconds <= 5) {
      return AppColors.timerYellow;
    }
    return AppColors.primaryCyan;
  }

  double _getGlowIntensity() {
    if (widget.seconds <= 3) {
      return 1.0;
    } else if (widget.seconds <= 5) {
      return 0.7;
    }
    return 0.4;
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.seconds / widget.maxSeconds;
    final timerColor = _getTimerColor();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: timerColor.withOpacity(0.5 * _getGlowIntensity()),
                blurRadius: _glowAnimation.value * _getGlowIntensity(),
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _TimerPainter(
              progress: progress,
              color: timerColor,
            ),
            child: Center(
              child: Text(
                '${widget.seconds}',
                style: AppTextStyles.timerMedium.copyWith(
                  color: timerColor,
                  fontSize: 48,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _TimerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.backgroundDark2
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
