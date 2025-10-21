import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Daily Quest or Reward Widget to motivate users
/// Displays the primary daily call-to-action for rewards
class DailyQuestWidget extends StatelessWidget {
  final String questTitle;
  final String questDescription;
  final int rewardCoins;
  final double progress;
  final VoidCallback? onTap;

  const DailyQuestWidget({
    Key? key,
    this.questTitle = 'Daily Quest',
    this.questDescription = 'Win 1 Duel',
    this.rewardCoins = 50,
    this.progress = 0.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.tertiaryGold.withOpacity(0.2),
              AppColors.gradientAmber.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.tertiaryGold.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiaryGold.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Quest Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.tertiaryGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.tertiaryGold,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.stars,
                color: AppColors.tertiaryGold,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Quest Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        questTitle,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.tertiaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Reward Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+$rewardCoins',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    questDescription,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.borderGlass,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.tertiaryGold,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multiple Daily Quests Carousel
class DailyQuestsCarousel extends StatelessWidget {
  const DailyQuestsCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: const [
          SizedBox(
            width: 320,
            child: DailyQuestWidget(
              questTitle: 'Daily Quest',
              questDescription: 'Win 1 Duel to claim reward',
              rewardCoins: 50,
              progress: 0.0,
            ),
          ),
          SizedBox(width: 16),
          SizedBox(
            width: 320,
            child: DailyQuestWidget(
              questTitle: 'Weekly Challenge',
              questDescription: 'Win 10 Duels this week',
              rewardCoins: 500,
              progress: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
