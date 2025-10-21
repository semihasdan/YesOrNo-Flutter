import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/animated_background.dart';
import '../controllers/user_controller.dart';

/// Marketplace Screen - Store for cosmetics and consumables
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back arrow
          title: Text(
            'Marketplace',
            style: AppTextStyles.heading1.copyWith(fontSize: 24),
          ),
          centerTitle: true,
          actions: [
            // Coin indicator from Firebase user data
            Consumer<UserController>(
              builder: (context, userController, _) {
                final coins = userController.currentUser?.coins ?? 0;
                
                return Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primaryCyan,
            labelColor: AppColors.primaryCyan,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Frames'),
              Tab(text: 'Bubbles'),
              Tab(text: 'Taunts'),
              Tab(text: 'Items'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAvatarFramesTab(),
            _buildBubbleSkinsTab(),
            _buildTauntsTab(),
            _buildItemsTab(),
          ],
        ),
      ),
    );
  }

  /// Avatar Frames Tab
  Widget _buildAvatarFramesTab() {
    final frames = [
      MarketplaceItem(
        id: 'frame_basic',
        name: 'Basic Frame',
        description: 'A simple cyan glow for your avatar',
        price: 0,
        type: MarketplaceItemType.avatarFrame,
        icon: Icons.account_circle,
        color: AppColors.primaryCyan,
        isOwned: true,
      ),
      MarketplaceItem(
        id: 'frame_raptor',
        name: 'Raptor Rank Frame',
        description: 'Golden frame for elite players',
        price: 500,
        type: MarketplaceItemType.avatarFrame,
        icon: Icons.stars,
        color: AppColors.tertiaryGold,
      ),
      MarketplaceItem(
        id: 'frame_neon',
        name: 'Neon Glitch Aura',
        description: 'Animated cyan-magenta glitch effect',
        price: 750,
        type: MarketplaceItemType.avatarFrame,
        icon: Icons.offline_bolt,
        color: AppColors.secondaryMagenta,
      ),
      MarketplaceItem(
        id: 'frame_holo',
        name: 'Holographic',
        description: 'Rainbow animated holographic frame',
        price: 1000,
        type: MarketplaceItemType.avatarFrame,
        icon: Icons.blur_on,
        color: AppColors.primaryCyan,
      ),
      MarketplaceItem(
        id: 'frame_legendary',
        name: 'Legendary Aura',
        description: 'Ultimate golden frame with particles',
        price: 2000,
        type: MarketplaceItemType.avatarFrame,
        icon: Icons.emoji_events,
        color: AppColors.tertiaryGold,
      ),
    ];

    return _buildMarketplaceGrid(frames);
  }

  /// Question Bubble Skins Tab
  Widget _buildBubbleSkinsTab() {
    final bubbles = [
      MarketplaceItem(
        id: 'bubble_default',
        name: 'Default',
        description: 'Standard question bubbles',
        price: 0,
        type: MarketplaceItemType.bubbleSkin,
        icon: Icons.chat_bubble,
        color: AppColors.primaryCyan,
        isOwned: true,
      ),
      MarketplaceItem(
        id: 'bubble_holo',
        name: 'Holographic',
        description: 'Shimmering holographic texture',
        price: 400,
        type: MarketplaceItemType.bubbleSkin,
        icon: Icons.auto_awesome,
        color: AppColors.gradientCerulean,
      ),
      MarketplaceItem(
        id: 'bubble_neon',
        name: 'Neon Pulse',
        description: 'Pulsing neon glow effect',
        price: 600,
        type: MarketplaceItemType.bubbleSkin,
        icon: Icons.lens_blur,
        color: AppColors.secondaryMagenta,
      ),
    ];

    return _buildMarketplaceGrid(bubbles);
  }

  /// Victory Taunts/Emotes Tab
  Widget _buildTauntsTab() {
    final taunts = [
      MarketplaceItem(
        id: 'taunt_gg',
        name: 'GG',
        description: '\"Good Game! 🎮\"',
        price: 100,
        type: MarketplaceItemType.taunt,
        icon: Icons.emoji_emotions,
        color: AppColors.yesGreen,
      ),
      MarketplaceItem(
        id: 'taunt_fire',
        name: 'On Fire',
        description: '\"🔥 Too Hot! 🔥\"',
        price: 150,
        type: MarketplaceItemType.taunt,
        icon: Icons.local_fire_department,
        color: AppColors.gradientAmber,
      ),
      MarketplaceItem(
        id: 'taunt_genius',
        name: 'Genius',
        description: '\"Big Brain Time! 🧠\"',
        price: 200,
        type: MarketplaceItemType.taunt,
        icon: Icons.psychology,
        color: AppColors.primaryCyan,
      ),
    ];

    return _buildMarketplaceGrid(taunts);
  }

  /// Consumable Items Tab (Hint Refills, etc.)
  Widget _buildItemsTab() {
    final items = [
      MarketplaceItem(
        id: 'hint_single',
        name: 'Hint Refill',
        description: 'Get 1 hint to use in duels',
        price: 50,
        type: MarketplaceItemType.consumable,
        icon: Icons.lightbulb,
        color: AppColors.tertiaryGold,
        isConsumable: true,
      ),
      MarketplaceItem(
        id: 'hint_pack5',
        name: 'Hint Pack (5x)',
        description: 'Get 5 hints - Better value!',
        price: 200,
        type: MarketplaceItemType.consumable,
        icon: Icons.card_giftcard,
        color: AppColors.tertiaryGold,
        isConsumable: true,
      ),
      MarketplaceItem(
        id: 'hint_pack10',
        name: 'Hint Pack (10x)',
        description: 'Get 10 hints - Best value!',
        price: 350,
        type: MarketplaceItemType.consumable,
        icon: Icons.redeem,
        color: AppColors.tertiaryGold,
        isConsumable: true,
      ),
    ];

    return _buildMarketplaceGrid(items);
  }

  /// Build marketplace grid layout
  Widget _buildMarketplaceGrid(List<MarketplaceItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildMarketplaceCard(items[index]);
      },
    );
  }

  /// Build individual marketplace card
  Widget _buildMarketplaceCard(MarketplaceItem item) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.color.withOpacity(0.2),
            item.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Name
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 48,
                  color: item.color,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.name,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.description,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Price and Buy Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: item.isOwned
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.yesGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.yesGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'OWNED',
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.yesGreen,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _purchaseItem(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.color,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 18,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
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

  /// Handle purchase
  void _purchaseItem(MarketplaceItem item) {
    print('[DEBUG] Purchase ${item.name} for ${item.price} coins');
    // TODO: Implement purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Purchased ${item.name}!'),
        backgroundColor: AppColors.yesGreen,
      ),
    );
  }
}

/// Marketplace Item Type
enum MarketplaceItemType {
  avatarFrame,
  bubbleSkin,
  taunt,
  consumable,
}

/// Marketplace Item Model
class MarketplaceItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final MarketplaceItemType type;
  final IconData icon;
  final Color color;
  final bool isOwned;
  final bool isConsumable;

  MarketplaceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.icon,
    required this.color,
    this.isOwned = false,
    this.isConsumable = false,
  });
}
