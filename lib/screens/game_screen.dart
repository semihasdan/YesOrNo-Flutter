
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/yes_no_logo.dart';
import '../widgets/home_header_widgets.dart';
import '../widgets/daily_quest_widget.dart';
import '../widgets/avatar_frame_widget.dart';
import '../providers/user_profile_provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  void _onQuickMatch(BuildContext context) {
    print('[DEBUG] Quick Match button pressed');
    Navigator.of(context).pushNamed(AppRoutes.matchmaking);
  }

  void _onPrivateRoom(BuildContext context) {
    print('[DEBUG] Private Room button pressed');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivateRoomBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(context),
              Expanded(
                child: _buildMainContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Header with Logo and User Avatar
  Widget _buildTopHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: User Avatar with Frame (shows off marketplace cosmetics)
          Consumer<UserProfileProvider>(
            builder: (context, provider, child) {
              final user = provider.userProfile;
              if (user == null) return const SizedBox.shrink();
              
              // Parse avatar frame style from string
              AvatarFrameStyle frameStyle = AvatarFrameStyle.basic;
              switch (user.avatarFrame.toLowerCase()) {
                case 'none':
                  frameStyle = AvatarFrameStyle.none;
                  break;
                case 'basic':
                  frameStyle = AvatarFrameStyle.basic;
                  break;
                case 'raptorrank':
                  frameStyle = AvatarFrameStyle.raptorRank;
                  break;
                case 'neonglitch':
                  frameStyle = AvatarFrameStyle.neonGlitch;
                  break;
                case 'holographic':
                  frameStyle = AvatarFrameStyle.holographic;
                  break;
                case 'legendary':
                  frameStyle = AvatarFrameStyle.legendary;
                  break;
              }
              
              return HomeHeaderAvatarWidget(
                imageUrl: user.avatar,
                frameStyle: frameStyle,
                onTap: () {
                  // Navigate to profile screen
                  print('[DEBUG] Avatar tapped - Navigate to Profile');
                },
              );
            },
          ),
          // Center: Yes/No Logo
          const YesNoLogo(size: 80),
          // Right: Coins & Leaderboard Button
          _buildCoinsAndLeaderboard(context),
        ],
      ),
    );
  }

  /// Coins display and leaderboard button
  Widget _buildCoinsAndLeaderboard(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, provider, child) {
        final coins = provider.userProfile?.coins ?? 0;
        
        return Row(
          children: [
            // Coins display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark2.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.tertiaryGold.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppColors.tertiaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$coins',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.tertiaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Leaderboard button
            GestureDetector(
              onTap: () {
                print('[DEBUG] Leaderboard button tapped');
                Navigator.of(context).pushNamed(AppRoutes.leaderboard);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark2.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryCyan.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.leaderboard,
                  color: AppColors.primaryCyan,
                  size: 22,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Main content area
  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildActionButtons(context),
          const SizedBox(height: 16),
          // "How to Play" Link
          const HowToPlayLink(),
          const SizedBox(height: 32),
          // Daily Quest Widget
          const DailyQuestWidget(
            questTitle: 'Daily Quest',
            questDescription: 'Win 1 Duel to claim +50 Coins',
            rewardCoins: 50,
            progress: 0.0,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Quick Match Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF14FFEC),
                  Color(0xFF0D9488),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onQuickMatch(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 132,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quick Match',
                        style: AppTextStyles.buttonLarge.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Private Room Button
          CustomButton(
            variant: ButtonVariant.secondary,
            onPressed: () => _onPrivateRoom(context),
            height: 132,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'Private Room',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Private Room Bottom Sheet (imported here for now)
class PrivateRoomBottomSheet extends StatelessWidget {
  const PrivateRoomBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xE61A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Private Room',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a room or join with a code',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 24),
          CustomButton(
            variant: ButtonVariant.primary,
            onPressed: () {
              print('[DEBUG] Create Room pressed');
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRoutes.lobby);
            },
            width: double.infinity,
            child: const Text('Create Room'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.borderGlass)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: AppTextStyles.subtitle),
              ),
              const Expanded(child: Divider(color: AppColors.borderGlass)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Enter Room Code',
              prefixIcon: Icon(Icons.key, color: AppColors.secondaryMagenta),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            variant: ButtonVariant.secondary,
            onPressed: () {
              print('[DEBUG] Join Room pressed');
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRoutes.lobby);
            },
            width: double.infinity,
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }
}
