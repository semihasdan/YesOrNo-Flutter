import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_or_no/controllers/user_controller.dart';
import 'package:yes_or_no/widgets/animated_background.dart';
import 'package:yes_or_no/widgets/profile_header_widget.dart';
import 'package:yes_or_no/widgets/game_statistics_widget.dart';
import 'package:yes_or_no/widgets/spinning_logo_loader.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Consumer<UserController>(
            builder: (context, userController, _) {
              // Show loading state
              if (userController.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SpinningLogoLoader(size: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Loading profile...',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show error state
              if (userController.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.noRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load profile',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userController.error ?? 'Unknown error',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => userController.initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Show profile data
              final userProfile = userController.currentUser;
              
              if (userProfile == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No user profile found',
                        style: AppTextStyles.heading2,
                      ),
                    ],
                  ),
                );
              }

              // Calculate statistics from user profile
              // TODO: These should come from actual game data in the future
              final gamesPlayed = userProfile.gamesPlayed;
              final wins = (gamesPlayed * 0.6).round(); // Placeholder calculation
              final losses = gamesPlayed - wins;
              final currentStreak = 5; // Placeholder - should come from game data

              return Column(
                children: [
                  ProfileHeaderWidget(userProfile: userProfile),
                  const SizedBox(height: 32),
                  Expanded(
                    child: GameStatisticsWidget(
                      wins: wins,
                      losses: losses,
                      currentStreak: currentStreak,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}