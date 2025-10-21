import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_container.dart';
import '../models/user_profile.dart';
import 'dart:math';

/// Lobby screen for private matches
class LobbyScreen extends StatefulWidget {
  final String? roomCode;

  const LobbyScreen({Key? key, this.roomCode}) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with SingleTickerProviderStateMixin {
  late String _roomCode;
  final UserProfile _player1 = UserProfile.mock();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _roomCode = widget.roomCode ?? _generateRoomCode();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: _roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room code copied to clipboard!'),
        backgroundColor: AppColors.primaryCyan,
        duration: Duration(seconds: 2),
      ),
    );
    print('[DEBUG] Room code copied: $_roomCode');
  }

  void _shareRoomCode() {
    print('[DEBUG] Share room code: $_roomCode');
    // In a real app, would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon!'),
        backgroundColor: AppColors.secondaryMagenta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Private Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print('[DEBUG] Settings pressed in lobby');
            },
          ),
        ],
      ),
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
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Room Code Display
              _buildRoomCodeDisplay(),
              
              const SizedBox(height: 48),
              
              // Player Slots
              Expanded(
                child: _buildPlayerSlots(),
              ),
              
              // Start Game Button (Disabled)
              _buildStartButton(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCodeDisplay() {
    return Column(
      children: [
        Text(
          'ROOM CODE',
          style: AppTextStyles.subtitle.copyWith(
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.3 * _pulseAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Text(
            _roomCode,
            style: AppTextStyles.timerLarge.copyWith(
              fontSize: 56,
              letterSpacing: 8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _copyRoomCode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryCyan),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.copy,
                      color: AppColors.primaryCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Copy',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _shareRoomCode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryCyan),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.share,
                      color: AppColors.primaryCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerSlots() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Player 1 (Filled)
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarWidget(
                  imageUrl: _player1.avatar,
                  size: AvatarSize.medium,
                  borderColor: AppColors.primaryCyan,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _player1.username,
                      style: AppTextStyles.heading4,
                    ),
                    Text(
                      'Host',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Player 2 (Empty)
          ScaleTransition(
            scale: _pulseAnimation,
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.textSecondary.withOpacity(0.3),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 40,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Waiting for opponent...',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: CustomButton(
        variant: ButtonVariant.primary,
        onPressed: null, // Disabled in prototype
        isEnabled: false,
        width: double.infinity,
        height: 56,
        child: const Text('Start Game'),
      ),
    );
  }
}
