import 'package:flutter/material.dart';
import 'package:yes_or_no/widgets/glass_container.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Widget displaying the user's game statistics
class GameStatisticsWidget extends StatelessWidget {
  const GameStatisticsWidget({
    Key? key,
    this.wins = 0,
    this.losses = 0,
    this.currentStreak = 0,
  }) : super(key: key);

  final int wins;
  final int losses;
  final int currentStreak;

  double get winRate {
    final totalGames = wins + losses;
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Game Statistics',
            style: AppTextStyles.heading2,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: [
              _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: AppColors.tertiaryGold,
                label: 'Wins',
                value: wins.toString(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.tertiaryGold.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.cancel,
                iconColor: AppColors.noRed,
                label: 'Losses',
                value: losses.toString(),
                gradient: LinearGradient(
                  colors: [
                    AppColors.noRed.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.star,
                iconColor: AppColors.yesGreen,
                label: 'Win Rate',
                value: '${winRate.toStringAsFixed(1)}%',
                gradient: LinearGradient(
                  colors: [
                    AppColors.yesGreen.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.trending_up,
                iconColor: AppColors.primaryCyan,
                label: 'Current Streak',
                value: '$currentStreak wins',
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Gradient gradient,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                fontSize: 20,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
