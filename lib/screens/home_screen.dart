import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_colors.dart';
import 'package:yes_or_no/core/theme/app_text_styles.dart';
import 'package:yes_or_no/widgets/avatar_widget.dart';
import 'package:yes_or_no/widgets/custom_button.dart';
import 'package:yes_or_no/widgets/progress_bar_widget.dart';
import 'package:yes_or_no/models/user_profile.dart';

/// Home screen with profile, action buttons, and bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final UserProfile _userProfile = UserProfile.mock();

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        // Leaderboard
        Navigator.of(context).pushNamed('/leaderboard');
        break;
      case 1:
        // Profile (already here)
        break;
      case 2:
        // Store
        Navigator.of(context).pushNamed('/store');
        break;
      case 3:
        // Settings
        Navigator.of(context).pushNamed('/settings');
        break;
    }
  }

  void _onQuickMatch() {
    print('[DEBUG] Quick Match button pressed');
    Navigator.of(context).pushNamed('/game');
  }

  void _onPrivateRoom() {
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
          child: Column(
            children: [
              // Profile Header
              _buildProfileHeader(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Expanded(
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Avatar with rank badge
          AvatarWidget(
            imageUrl: _userProfile.avatar,
            size: AvatarSize.large,
            borderColor: AppColors.primaryCyan,
            badge: _userProfile.rankIcon,
          ),
          
          const SizedBox(height: 16),
          
          // Username
          Text(
            _userProfile.username,
            style: AppTextStyles.heading2,
          ),
          
          const SizedBox(height: 8),
          
          // Rank
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.military_tech,
                color: AppColors.tertiaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _userProfile.rank,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.tertiaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // XP Progress Bar
          ProgressBarWidget(
            current: _userProfile.xp,
            max: _userProfile.xpMax,
            color: AppColors.primaryCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
                onTap: _onQuickMatch,
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
            onPressed: _onPrivateRoom,
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

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark2.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.leaderboard, 'Leaderboard', 0),
              _buildNavItem(Icons.person, 'Profile', 1),
              _buildNavItem(Icons.store, 'Store', 2),
              _buildNavItem(Icons.settings, 'Settings', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onBottomNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryCyan : AppColors.textSecondary,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: isSelected ? AppColors.primaryCyan : AppColors.textSecondary,
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
              Navigator.of(context).pushNamed('/lobby');
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
              Navigator.of(context).pushNamed('/lobby');
            },
            width: double.infinity,
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }
}
