import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/equippable_avatar_frame.dart';

/// Header widget displaying user avatar with frame for Home Screen
/// Small, interactive widget that emphasizes equipped cosmetics
class HomeHeaderAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final String frameId;
  final VoidCallback? onTap;

  const HomeHeaderAvatarWidget({
    Key? key,
    required this.imageUrl,
    this.frameId = 'basic',
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: EquippableAvatarFrame(
          avatarUrl: imageUrl,
          frameId: frameId,
          radius: 25,
        ),
      ),
    );
  }
}

/// How to Play link widget
/// Elegantly designed text link for onboarding guidance
class HowToPlayLink extends StatelessWidget {
  final VoidCallback? onTap;

  const HowToPlayLink({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // TODO: Navigate to How to Play screen
        showDialog(
          context: context,
          builder: (context) => const HowToPlayDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              color: AppColors.primaryCyan,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'New to the Duel? See How to Play',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primaryCyan,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How to Play Dialog
class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryCyan.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                const Icon(
                  Icons.school,
                  color: AppColors.primaryCyan,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'How to Play',
                  style: AppTextStyles.heading2,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Instructions
            _buildInstructionStep(
              1,
              'Choose Quick Match or create a Private Room',
              Icons.flash_on,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              2,
              'Answer YES or NO questions faster than your opponent',
              Icons.quiz,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              3,
              'Win rounds to increase your score and rank',
              Icons.emoji_events,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              4,
              'Complete Daily Quests to earn coins and unlock cosmetics',
              Icons.stars,
            ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got It!',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int step, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryCyan,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTextStyles.subtitle.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Icon
        Icon(
          icon,
          color: AppColors.primaryCyan,
          size: 24,
        ),
        const SizedBox(width: 12),
        // Text
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }
}
