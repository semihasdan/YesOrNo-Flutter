import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';

/// Reusable widget for displaying avatar with equippable decorative frames
/// The frame design is determined by the frameId parameter
class EquippableAvatarFrame extends StatefulWidget {
  /// URL for the user's profile image
  final String avatarUrl;

  /// Identifier for the frame style (e.g., "basic", "premium_gold", "rank_bronze")
  final String frameId;

  /// Size of the avatar (radius)
  final double radius;

  /// Optional tap callback
  final VoidCallback? onTap;

  const EquippableAvatarFrame({
    Key? key,
    required this.avatarUrl,
    required this.frameId,
    this.radius = 40.0,
    this.onTap,
  }) : super(key: key);

  @override
  State<EquippableAvatarFrame> createState() => _EquippableAvatarFrameState();
}

class _EquippableAvatarFrameState extends State<EquippableAvatarFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Start animation for animated frames
    if (_isAnimatedFrame()) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isAnimatedFrame() {
    return widget.frameId == 'event_neon_pulse' ||
        widget.frameId == 'legendary_flames' ||
        widget.frameId == 'holographic_aurora' ||
        widget.frameId == 'rank_diamond';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Frame decoration (rendered behind avatar)
            _buildFrame(),
            // Avatar image
            _buildAvatar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: widget.radius * 2 - _getFrameThickness() * 2,
      height: widget.radius * 2 - _getFrameThickness() * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.avatarUrl,
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
              size: widget.radius,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrame() {
    // Use a map to select the correct frame based on frameId
    final frameBuilders = <String, Widget Function()>{
      'basic': _buildBasicFrame,
      'default_frame': _buildBasicFrame,
      'premium_gold': _buildPremiumGoldFrame,
      'rank_bronze': _buildRankBronzeFrame,
      'rank_silver': _buildRankSilverFrame,
      'rank_gold': _buildRankGoldFrame,
      'rank_platinum': _buildRankPlatinumFrame,
      'rank_diamond': _buildRankDiamondFrame,
      'event_neon_pulse': _buildEventNeonPulseFrame,
      'legendary_flames': _buildLegendaryFlamesFrame,
      'holographic_aurora': _buildHolographicAuroraFrame,
    };

    final builder = frameBuilders[widget.frameId] ?? _buildBasicFrame;
    return builder();
  }

  double _getFrameThickness() {
    switch (widget.frameId) {
      case 'basic':
      case 'default_frame':
        return 2.0;
      case 'premium_gold':
      case 'rank_bronze':
      case 'rank_silver':
        return 4.0;
      case 'rank_gold':
      case 'rank_platinum':
        return 5.0;
      case 'rank_diamond':
      case 'event_neon_pulse':
      case 'legendary_flames':
      case 'holographic_aurora':
        return 6.0;
      default:
        return 2.0;
    }
  }

  // ============================================================
  // FRAME STYLES LIBRARY
  // ============================================================

  /// Basic Frame - Simple thin border
  Widget _buildBasicFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2.0,
        ),
      ),
    );
  }

  /// Premium Gold Frame - Thick metallic gold frame with gradient
  Widget _buildPremiumGoldFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFFFD700), // Gold
            Color(0xFFFFE55C), // Light gold
            Color(0xFFB8860B), // Dark gold
            Color(0xFFFFD700), // Gold (to complete the sweep)
          ],
          stops: [0.0, 0.33, 0.66, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  /// Rank Bronze Frame - Bronze metallic frame
  Widget _buildRankBronzeFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCD7F32), // Bronze
            Color(0xFFB87333), // Dark bronze
            Color(0xFFE6A85C), // Light bronze
            Color(0xFFCD7F32), // Bronze
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCD7F32).withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  /// Rank Silver Frame - Silver metallic frame
  Widget _buildRankSilverFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFC0C0C0), // Silver
            Color(0xFFE8E8E8), // Light silver
            Color(0xFF999999), // Dark silver
            Color(0xFFC0C0C0), // Silver
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0C0C0).withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  /// Rank Gold Frame - Enhanced gold frame
  Widget _buildRankGoldFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: [
            Color(0xFFFFD700),
            Color(0xFFFFE55C),
            Color(0xFFFFAA00),
            Color(0xFFB8860B),
            Color(0xFFFFD700),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiaryGold.withOpacity(0.6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  /// Rank Platinum Frame - Platinum/white metallic frame
  Widget _buildRankPlatinumFrame() {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE5E4E2), // Platinum
            Color(0xFFFFFFFF), // White
            Color(0xFFCCCCCC), // Light gray
            Color(0xFFE5E4E2), // Platinum
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Rank Diamond Frame - Sparkling diamond frame with animation
  Widget _buildRankDiamondFrame() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  AppColors.primaryCyan,
                  Colors.white,
                  AppColors.secondaryMagenta,
                  Colors.white,
                  AppColors.primaryCyan,
                ],
                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.7),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Event Neon Pulse Frame - Glowing neon effect with pulsing animation
  Widget _buildEventNeonPulseFrame() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.radius * 2,
          height: widget.radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryCyan,
                AppColors.secondaryMagenta,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryCyan.withOpacity(0.8 * _pulseAnimation.value),
                blurRadius: 25 * _pulseAnimation.value,
                spreadRadius: 3 * _pulseAnimation.value,
              ),
              BoxShadow(
                color: AppColors.secondaryMagenta.withOpacity(0.6 * _pulseAnimation.value),
                blurRadius: 30 * _pulseAnimation.value,
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Legendary Flames Frame - Animated flame effect
  Widget _buildLegendaryFlamesFrame() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFFFF4500), // Orange-red
                    Color(0xFFFFD700), // Gold
                    Color(0xFFFF6347), // Tomato
                    Color(0xFFFF4500), // Orange-red
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4500).withOpacity(0.8),
                    blurRadius: 25 * _pulseAnimation.value,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: AppColors.tertiaryGold.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Flame particles
            ..._buildFlameParticles(),
          ],
        );
      },
    );
  }

  List<Widget> _buildFlameParticles() {
    return List.generate(8, (index) {
      final angle = (index * 45) * math.pi / 180;
      final distance = widget.radius + 8;
      return Positioned(
        left: widget.radius + distance * math.cos(angle),
        top: widget.radius + distance * math.sin(angle),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 2 == 0
                      ? const Color(0xFFFF4500)
                      : AppColors.tertiaryGold,
                  boxShadow: [
                    BoxShadow(
                      color: (index % 2 == 0
                              ? const Color(0xFFFF4500)
                              : AppColors.tertiaryGold)
                          .withOpacity(0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Holographic Aurora Frame - Rainbow gradient with rotation
  Widget _buildHolographicAuroraFrame() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  AppColors.primaryCyan,
                  AppColors.secondaryMagenta,
                  AppColors.tertiaryGold,
                  Color(0xFF00FF88), // Green
                  AppColors.yesGreen,
                  AppColors.primaryCyan,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.secondaryMagenta.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
