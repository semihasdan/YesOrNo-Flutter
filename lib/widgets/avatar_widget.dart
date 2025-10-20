import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';

/// Avatar size presets
enum AvatarSize {
  small,  // 48.0
  medium, // 80.0
  large,  // 128.0
}

/// Custom avatar widget with optional rank badge
class AvatarWidget extends StatelessWidget {
  final String imageUrl;
  final AvatarSize size;
  final Color borderColor;
  final String? badge;
  final double borderWidth;

  const AvatarWidget({
    Key? key,
    required this.imageUrl,
    this.size = AvatarSize.medium,
    this.borderColor = AppColors.primaryCyan,
    this.badge,
    this.borderWidth = 2.0,
  }) : super(key: key);

  double get _size {
    switch (size) {
      case AvatarSize.small:
        return 48.0;
      case AvatarSize.medium:
        return 80.0;
      case AvatarSize.large:
        return 128.0;
    }
  }

  double get _badgeSize {
    switch (size) {
      case AvatarSize.small:
        return 16.0;
      case AvatarSize.medium:
        return 24.0;
      case AvatarSize.large:
        return 32.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundDark2,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryCyan,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.backgroundDark2,
                child: Icon(
                  Icons.person,
                  size: _size * 0.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              width: _badgeSize,
              height: _badgeSize,
              decoration: BoxDecoration(
                color: AppColors.tertiaryGold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.backgroundDark,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.military_tech,
                size: _badgeSize * 0.6,
                color: Colors.black,
              ),
            ),
          ),
      ],
    );
  }
}
