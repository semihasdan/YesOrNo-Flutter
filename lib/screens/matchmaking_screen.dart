import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../models/user_profile.dart';
import '../widgets/equippable_avatar_frame.dart';
import '../widgets/spinning_logo_loader.dart';
import '../controllers/user_controller.dart';

/// Matchmaking screen - Shows when players are matched
/// Displays player profiles and transitions to game
class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({Key? key}) : super(key: key);

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final UserProfile _player2 = UserProfile.mock(
    userId: 'opponent_123',
    username: 'Opponent',
    avatar: 'https://i.pravatar.cc/150?img=2',
    rank: 'Silver Rank',
    xp: 450,
    xpMax: 600,
  );

  @override
  void initState() {
    super.initState();

    // Pulse animation for VS text
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-navigate to game after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.game);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundDark2,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background gradients and divider
              _buildBackgroundEffects(),

              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // Game mode info
                      _buildGameModeInfo(),

                      const SizedBox(height: 48),

                      // Players matchup
                      _buildPlayersMatchup(),

                      const Spacer(),

                      // Loading indicator with message
                      _buildLoadingSection(),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        // Left gradient (cyan)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF00FFFF).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Right gradient (orange/red)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  const Color(0xFFFF00FF).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Center divider line with glow
        Positioned(
          left: MediaQuery.of(context).size.width * 0.5 - 1,
          top: 0,
          bottom: 0,
          width: 2,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2 * _pulseAnimation.value),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3 * _pulseAnimation.value),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameModeInfo() {
    return Column(
      children: [
        Text(
          'Quick Match',
          style: AppTextStyles.heading3.copyWith(
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Word Deduction Duel',
          style: AppTextStyles.subtitle.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersMatchup() {
    return Consumer<UserController>(
      builder: (context, userController, _) {
        final player1 = userController.currentUser ?? UserProfile.mock(username: 'You');
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Player 1
            Expanded(
              child: _buildPlayerCard(
                player: player1,
                borderColor: const Color(0xFF00FFFF), // Cyan
                shadowColor: const Color(0xFF00FFFF),
              ),
            ),

            // VS text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF00FFFF),
                          Color(0xFFFF00FF),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'VS',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Player 2
            Expanded(
              child: _buildPlayerCard(
                player: _player2,
                borderColor: const Color(0xFFFF00FF), // Orange/Red
                shadowColor: const Color(0xFFFF00FF),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerCard({
    required UserProfile player,
    required Color borderColor,
    required Color shadowColor,
  }) {
    return Column(
      children: [
        // Avatar with glow
        Container(
          width: 100,
          height: 100,
          child: EquippableAvatarFrame(
            avatarUrl: player.avatar,
            frameId: player.avatarFrame,
            radius: 50,
          ),
        ),

        const SizedBox(height: 16),

        // Player name
        Text(
          player.username,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Level
        Text(
          player.rank,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // Win rate (placeholder)
        Text(
          'Win Rate: ${(player.xp / player.xpMax * 100).toStringAsFixed(0)}%',
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Spinning logo loader
        const SpinningLogoLoader(size: 100),

        const SizedBox(height: 24),

        // Loading message
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: 0.5 + (0.5 * _pulseAnimation.value),
              child: child,
            );
          },
          child: Text(
            'Preparing the duel...',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
