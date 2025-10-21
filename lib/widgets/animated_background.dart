import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../core/theme/app_colors.dart';

/// An enhanced animated background with floating particles and gradient overlay
/// designed to be more attractive and compatible with the game's main colors
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    Key? key,
    required this.child,
    this.showParticles = true,
  }) : super(key: key);

  final Widget child;
  final bool showParticles;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    if (widget.showParticles) {
      _particles = List.generate(
        15,
        (index) => Particle(
          color: _getRandomColor(index),
          size: math.Random().nextDouble() * 6 + 3,
          initialX: math.Random().nextDouble(),
          initialY: math.Random().nextDouble(),
          speed: math.Random().nextDouble() * 0.5 + 0.3,
          angle: math.Random().nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  Color _getRandomColor(int index) {
    final colors = [
      AppColors.primaryCyan.withOpacity(0.4),
      AppColors.secondaryMagenta.withOpacity(0.4),
      AppColors.tertiaryGold.withOpacity(0.3),
      AppColors.magentaVariant.withOpacity(0.3),
    ];
    return colors[index % colors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A192F), // backgroundDark
            Color(0xFF1A0B2E), // Deep purple tint
            Color(0xFF0D1B2A), // backgroundDark2
            Color(0xFF16213E), // Navy blue tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Radial gradient overlays for depth
          Positioned.fill(
            child: CustomPaint(
              painter: RadialGradientPainter(),
            ),
          ),
          // Floating particles
          if (widget.showParticles)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlesPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

/// Painter for radial gradient effects
class RadialGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top-left cyan glow
    final cyanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryCyan.withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.2, size.height * 0.1),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.1),
      size.width * 0.5,
      cyanPaint,
    );

    // Bottom-right magenta glow
    final magentaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondaryMagenta.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.8),
          radius: size.width * 0.5,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      size.width * 0.5,
      magentaPaint,
    );

    // Center gold accent
    final goldPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.tertiaryGold.withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.8],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.5),
          radius: size.width * 0.4,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.4,
      goldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Particle data model
class Particle {
  final Color color;
  final double size;
  final double initialX;
  final double initialY;
  final double speed;
  final double angle;

  Particle({
    required this.color,
    required this.size,
    required this.initialX,
    required this.initialY,
    required this.speed,
    required this.angle,
  });
}

/// Painter for animated floating particles
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlesPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final x = (particle.initialX * size.width +
              math.cos(particle.angle) * progress * size.width * particle.speed) %
          size.width;
      final y = (particle.initialY * size.height +
              math.sin(particle.angle) * progress * size.height * particle.speed) %
          size.height;

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size);

      canvas.drawCircle(
        Offset(x, y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
