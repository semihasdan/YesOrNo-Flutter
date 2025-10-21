import 'package:flutter/material.dart';
import 'package:yes_or_no/models/user_profile.dart';
import 'package:yes_or_no/widgets/avatar_widget.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Widget displaying the user's profile header with avatar, username, and rank
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    Key? key,
    required this.userProfile,
  }) : super(key: key);

  final UserProfile userProfile;

  /// Map rank names to tier images
  String _getRankImagePath(String rank) {
    final rankLower = rank.toLowerCase();
    
    if (rankLower.contains('bronze') || rankLower.contains('tier1')) {
      return 'assets/ranks_logo/tier6.png';
    } else if (rankLower.contains('silver') || rankLower.contains('tier2')) {
      return 'assets/ranks_logo/tier2.png';
    } else if (rankLower.contains('gold') || rankLower.contains('tier3')) {
      return 'assets/ranks_logo/tier3.png';
    } else if (rankLower.contains('platinum') || rankLower.contains('tier4')) {
      return 'assets/ranks_logo/tier4.png';
    } else if (rankLower.contains('diamond') || rankLower.contains('tier5')) {
      return 'assets/ranks_logo/tier5.png';
    } else if (rankLower.contains('master') || rankLower.contains('legend') || rankLower.contains('tier6')) {
      return 'assets/ranks_logo/tier6.png';
    }
    
    // Default to tier1 if no match
    return 'assets/ranks_logo/tier1.png';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Avatar with rank badge
          AvatarWidget(
            imageUrl: userProfile.avatar,
            size: AvatarSize.large,
            borderColor: AppColors.primaryCyan,
            badge: userProfile.rankIcon,
          ),
          const SizedBox(width: 16),
          // Username and Rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile.username,
                  style: AppTextStyles.heading2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Rank with image
                Row(
                  children: [
                    // Rank image
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiaryGold.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Transform.scale(
                          scale: 6.5,
                          child: Image.asset(
                            _getRankImagePath(userProfile.rank),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to icon if image fails to load
                              return const Icon(
                                Icons.military_tech,
                                color: AppColors.tertiaryGold,
                                size: 40,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Rank text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProfile.rank,
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.tertiaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // XP Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: userProfile.xp / userProfile.xpMax,
                              backgroundColor: AppColors.borderGlass,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryCyan,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${userProfile.xp}/${userProfile.xpMax} XP',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
