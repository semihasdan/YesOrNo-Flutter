import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Avatar Frame styles available in the Marketplace
enum AvatarFrameStyle {
  none,
  basic,
  raptorRank,
  neonGlitch,
  holographic,
  legendary,
}

/// Avatar widget with customizable frame (purchased from Marketplace)
/// This widget displays the user avatar with an equipped frame
class AvatarFrameWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final AvatarFrameStyle frameStyle;
  final VoidCallback? onTap;

  const AvatarFrameWidget({
    Key? key,
    required this.imageUrl,
    this.size = 60.0,
    this.frameStyle = AvatarFrameStyle.none,
    this.onTap,
  }) : super(key: key);

  /// Get frame configuration based on style
  FrameConfig _getFrameConfig() {
    switch (frameStyle) {
      case AvatarFrameStyle.none:
        return FrameConfig(
          colors: [AppColors.borderGlass, AppColors.borderGlass],
          width: 2.0,
          glowRadius: 0,
        );
      case AvatarFrameStyle.basic:
        return FrameConfig(
          colors: [AppColors.primaryCyan, AppColors.primaryCyan],
          width: 3.0,
          glowRadius: 8,
        );
      case AvatarFrameStyle.raptorRank:
        return FrameConfig(
          colors: [AppColors.tertiaryGold, AppColors.gradientAmber],
          width: 4.0,
          glowRadius: 12,
        );
      case AvatarFrameStyle.neonGlitch:
        return FrameConfig(
          colors: [AppColors.primaryCyan, AppColors.secondaryMagenta],
          width: 4.0,
          glowRadius: 15,
          animated: true,
        );
      case AvatarFrameStyle.holographic:
        return FrameConfig(
          colors: [
            AppColors.primaryCyan,
            AppColors.secondaryMagenta,
            AppColors.tertiaryGold,
            AppColors.yesGreen,
          ],
          width: 4.0,
          glowRadius: 18,
          animated: true,
        );
      case AvatarFrameStyle.legendary:
        return FrameConfig(
          colors: [
            AppColors.tertiaryGold,
            AppColors.gradientAmber,
            AppColors.tertiaryGold,
          ],
          width: 5.0,
          glowRadius: 20,
          animated: true,
          showParticles: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getFrameConfig();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: config.glowRadius > 0
              ? [
                  BoxShadow(
                    color: config.colors.first.withOpacity(0.5),
                    blurRadius: config.glowRadius,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Avatar with frame border
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: config.colors.length > 1
                    ? LinearGradient(
                        colors: config.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: config.colors.length == 1 ? config.colors.first : null,
              ),
              padding: EdgeInsets.all(config.width),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundDark2,
                      child: Icon(
                        Icons.person,
                        size: size * 0.5,
                        color: AppColors.textSecondary,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Particle effects for legendary frame
            if (config.showParticles)
              ...List.generate(8, (index) {
                final angle = (index * 45) * 3.14159 / 180;
                return Positioned(
                  top: size / 2 + (size / 2 - 10) * -1 * (1 + 0.1 * (index % 2)) * (angle < 3.14159 ? 1 : -1),
                  left: size / 2 + (size / 2 - 10) * (angle < 3.14159 / 2 || angle > 3 * 3.14159 / 2 ? 1 : -1),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tertiaryGold,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiaryGold.withOpacity(0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/// Frame configuration
class FrameConfig {
  final List<Color> colors;
  final double width;
  final double glowRadius;
  final bool animated;
  final bool showParticles;

  FrameConfig({
    required this.colors,
    required this.width,
    required this.glowRadius,
    this.animated = false,
    this.showParticles = false,
  });
}
