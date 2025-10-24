import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/equippable_avatar_frame.dart';
import '../controllers/user_controller.dart';

/// Demo screen showcasing all available avatar frames
/// Use this screen to test and preview frame styles
class FrameShowcaseScreen extends StatelessWidget {
  const FrameShowcaseScreen({Key? key}) : super(key: key);

  // All available frame IDs and their metadata
  static const List<Map<String, dynamic>> availableFrames = [
    {'id': 'basic', 'name': 'Basic Frame', 'cost': 0, 'rarity': 'Common'},
    {'id': 'default_frame', 'name': 'Default Frame', 'cost': 0, 'rarity': 'Common'},
    {'id': 'premium_gold', 'name': 'Premium Gold', 'cost': 500, 'rarity': 'Premium'},
    {'id': 'rank_bronze', 'name': 'Bronze Rank', 'cost': 200, 'rarity': 'Rare'},
    {'id': 'rank_silver', 'name': 'Silver Rank', 'cost': 400, 'rarity': 'Rare'},
    {'id': 'rank_gold', 'name': 'Gold Rank', 'cost': 600, 'rarity': 'Epic'},
    {'id': 'rank_platinum', 'name': 'Platinum Rank', 'cost': 800, 'rarity': 'Epic'},
    {'id': 'rank_diamond', 'name': 'Diamond Rank', 'cost': 1000, 'rarity': 'Legendary'},
    {'id': 'event_neon_pulse', 'name': 'Neon Pulse', 'cost': 750, 'rarity': 'Event'},
    {'id': 'legendary_flames', 'name': 'Legendary Flames', 'cost': 1500, 'rarity': 'Legendary'},
    {'id': 'holographic_aurora', 'name': 'Holographic Aurora', 'cost': 1200, 'rarity': 'Legendary'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Avatar Frame Showcase'),
        backgroundColor: AppColors.backgroundDark2,
        elevation: 0,
        actions: [
          // Add Coins Button (for testing)
          Consumer<UserController>(
            builder: (context, controller, _) {
              final coins = controller.currentUser?.coins ?? 0;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    tooltip: 'Add 1000 coins',
                    onPressed: () async {
                      await controller.addCoins(1000);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added 1000 coins!'),
                            backgroundColor: AppColors.tertiaryGold,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on, color: AppColors.tertiaryGold, size: 20),
                        const SizedBox(width: 4),
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
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<UserController>(
        builder: (context, userController, _) {
          final user = userController.currentUser;
          if (user == null) {
            return const Center(child: Text('No user profile found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Frame Display
                _buildCurrentFrameSection(user.avatar, user.avatarFrame),
                
                const SizedBox(height: 16),
                
                // Debug Info Card
                _buildDebugInfoCard(user),
                
                const SizedBox(height: 32),
                
                // All Frames Grid
                Text(
                  'Available Frames',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: availableFrames.length,
                  itemBuilder: (context, index) {
                    final frameData = availableFrames[index];
                    final isUnlocked = user.unlockedFrames.contains(frameData['id']);
                    final isEquipped = user.avatarFrame == frameData['id'];
                    
                    return _buildFrameCard(
                      context,
                      user.avatar,
                      frameData,
                      isUnlocked,
                      isEquipped,
                      userController,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentFrameSection(String avatarUrl, String currentFrameId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Currently Equipped',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          EquippableAvatarFrame(
            avatarUrl: avatarUrl,
            frameId: currentFrameId,
            radius: 60,
          ),
          const SizedBox(height: 12),
          Text(
            _getFrameName(currentFrameId),
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameCard(
    BuildContext context,
    String avatarUrl,
    Map<String, dynamic> frameData,
    bool isUnlocked,
    bool isEquipped,
    UserController controller,
  ) {
    final frameId = frameData['id'] as String;
    final frameName = frameData['name'] as String;
    final cost = frameData['cost'] as int;
    final rarity = frameData['rarity'] as String;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped
              ? AppColors.primaryCyan
              : isUnlocked
                  ? AppColors.yesGreen.withOpacity(0.5)
                  : AppColors.borderGlass,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Frame Preview
          Stack(
            alignment: Alignment.center,
            children: [
              EquippableAvatarFrame(
                avatarUrl: avatarUrl,
                frameId: frameId,
                radius: 50,
              ),
              if (!isUnlocked)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              if (isEquipped)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Frame Name
          Text(
            frameName,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Rarity Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getRarityColor(rarity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rarity,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 10,
                color: _getRarityColor(rarity),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Action Button
          if (!isUnlocked && cost > 0)
            ElevatedButton(
              onPressed: () async {
                // Simulate purchase
                final success = await controller.purchaseFrame(frameId, cost);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Frame unlocked! ($frameId)'
                            : 'Not enough coins!',
                      ),
                      backgroundColor: success
                          ? AppColors.yesGreen
                          : AppColors.noRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiaryGold,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: Text(
                '$cost coins',
                style: const TextStyle(fontSize: 10, color: Colors.black),
              ),
            )
          else if (isUnlocked && !isEquipped)
            ElevatedButton(
              onPressed: () async {
                final success = await controller.equipAvatarFrame(frameId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Frame equipped! ($frameId)'
                            : 'Failed to equip frame',
                      ),
                      backgroundColor: success
                          ? AppColors.primaryCyan
                          : AppColors.noRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: const Text(
                'Equip',
                style: TextStyle(fontSize: 10),
              ),
            )
          else if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Equipped',
                style: TextStyle(fontSize: 10, color: AppColors.primaryCyan),
              ),
            ),
        ],
      ),
    );
  }

  String _getFrameName(String frameId) {
    final frame = availableFrames.firstWhere(
      (f) => f['id'] == frameId,
      orElse: () => {'name': frameId},
    );
    return frame['name'] as String;
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return AppColors.tertiaryGold;
      case 'event':
        return AppColors.secondaryMagenta;
      case 'premium':
        return AppColors.primaryCyan;
      default:
        return Colors.white;
    }
  }
}
