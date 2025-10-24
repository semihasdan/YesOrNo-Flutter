# Equippable Avatar Frame System - Implementation Guide

## Overview
This document describes the complete implementation of the reusable and equippable avatar frame system in the Yes Or No application.

## System Architecture

### Core Components

#### 1. **EquippableAvatarFrame Widget** (`lib/widgets/equippable_avatar_frame.dart`)
A reusable Flutter widget that displays a user's avatar with a decorative frame.

**Parameters:**
- `avatarUrl` (required): URL for the user's profile image
- `frameId` (required): Identifier for the frame style (e.g., "basic", "premium_gold", "rank_bronze")
- `radius`: Size of the avatar (default: 40.0)
- `onTap`: Optional callback for tap events

**Features:**
- Uses `Stack` to overlay frame decoration on the avatar
- Supports both static and animated frames
- Frame selection via `frameId` parameter using a Map-based lookup
- Includes `CachedNetworkImage` for efficient image loading
- Animations controlled by `AnimationController` for dynamic frames

#### 2. **UserProfile Model** (`lib/models/user_profile.dart`)
Extended to support frame system with the following fields:

```dart
final String avatarFrame;           // Currently equipped frame ID
final String activeFrameId;         // Alternative field for active frame
final List<String> unlockedFrames;  // List of frame IDs the user owns
```

**Default Values:**
- `avatarFrame`: 'basic'
- `activeFrameId`: 'default_frame'
- `unlockedFrames`: ['basic', 'default_frame']

#### 3. **UserProfileProvider** (`lib/providers/user_profile_provider.dart`)
State management provider with frame-related methods:

```dart
// Equip a frame (must be unlocked first)
bool equipAvatarFrame(String frameId)

// Unlock a new frame (typically after purchase)
void unlockFrame(String frameId)

// Purchase and unlock a frame (checks coins, deducts cost)
bool purchaseFrame(String frameId, int cost)

// Check if a frame is unlocked
bool isFrameUnlocked(String frameId)
```

## Available Frame Styles

### 1. **Basic Frame** (`basic` / `default_frame`)
- **Rarity:** Common
- **Cost:** Free
- **Description:** Simple thin gray border
- **Implementation:** `BoxDecoration` with solid border

### 2. **Premium Gold** (`premium_gold`)
- **Rarity:** Premium
- **Cost:** 500 coins
- **Description:** Thick metallic gold frame with gradient
- **Implementation:** `SweepGradient` with gold/yellow/brown colors and shadow

### 3. **Rank Frames**

#### Bronze (`rank_bronze`)
- **Cost:** 200 coins
- **Description:** Bronze metallic frame
- **Gradient:** Linear gradient with bronze tones

#### Silver (`rank_silver`)
- **Cost:** 400 coins
- **Description:** Silver metallic frame
- **Gradient:** Linear gradient with silver tones

#### Gold (`rank_gold`)
- **Cost:** 600 coins
- **Description:** Enhanced gold frame
- **Gradient:** Sweep gradient with gold variations

#### Platinum (`rank_platinum`)
- **Cost:** 800 coins
- **Description:** Platinum/white metallic frame
- **Gradient:** Linear gradient with platinum tones

#### Diamond (`rank_diamond`)
- **Cost:** 1000 coins
- **Description:** Sparkling diamond frame with rotation animation
- **Animation:** Continuous rotation of sweep gradient
- **Special:** Uses `AnimatedBuilder` with rotation effect

### 4. **Event Frames**

#### Neon Pulse (`event_neon_pulse`)
- **Cost:** 750 coins
- **Description:** Glowing neon effect with pulsing animation
- **Animation:** Pulsing glow intensity using `AnimatedBuilder`
- **Colors:** Cyan and magenta gradient

#### Legendary Flames (`legendary_flames`)
- **Cost:** 1500 coins
- **Description:** Animated flame effect with particles
- **Animation:** Pulsing flames with rotating particles
- **Special:** 8 flame particles positioned around the avatar

#### Holographic Aurora (`holographic_aurora`)
- **Cost:** 1200 coins
- **Description:** Rainbow gradient with rotation
- **Animation:** Rotating sweep gradient
- **Colors:** Cyan, magenta, gold, green cycle

## Integration Points

The system has been integrated into the following screens:

### 1. **ProfileScreen** (`lib/screens/profile_screen.dart`)
- Uses `EquippableAvatarFrame` in `ProfileHeaderWidget`
- Displays large avatar (radius: 64.0)
- Shows currently equipped frame

### 2. **HomeScreen/GameScreen** (`lib/screens/game_screen.dart`)
- Uses `HomeHeaderAvatarWidget` which wraps `EquippableAvatarFrame`
- Displays small avatar (radius: 25)
- Shown in top-left corner of game screen

### 3. **LobbyScreen** (`lib/screens/lobby_screen.dart`)
- Shows player's avatar with frame
- Medium size (radius: 40)

### 4. **MatchmakingScreen** (`lib/screens/matchmaking_screen.dart`)
- Displays both players' avatars with frames
- Medium-large size (radius: 50)

### 5. **LeaderboardScreen** (`lib/screens/leaderboard_screen.dart`)
- Shows small avatar frames for each player
- Small size (radius: 24)

### 6. **FrameShowcaseScreen** (`lib/screens/frame_showcase_screen.dart`)
- Demo/test screen showing all available frames
- Allows testing purchase and equip functionality
- Grid layout with frame previews

## State Management Flow

### Equipping a Frame

```dart
// 1. User taps "Equip" button
// 2. Call provider method
final provider = context.read<UserProfileProvider>();
provider.equipAvatarFrame('premium_gold');

// 3. Provider updates state
// 4. All EquippableAvatarFrame widgets automatically rebuild
// 5. New frame is displayed across the app
```

### Purchasing a Frame

```dart
// 1. User taps "Buy" button
// 2. Check if user has enough coins
final provider = context.read<UserProfileProvider>();
final success = provider.purchaseFrame('legendary_flames', 1500);

// 3. If successful:
//    - Coins are deducted
//    - Frame is added to unlockedFrames list
//    - State updates and UI refreshes
```

### Data Persistence

The system integrates with Firestore through:
- `UserProfile.toFirestore()`: Serializes frame data
- `UserProfile.fromFirestore()`: Deserializes frame data
- `unlockedFrames` field is stored as an array in Firestore
- `avatarFrame` field stores the currently equipped frame ID

## Marketplace Integration (Conceptual)

The Marketplace screen can:

1. **Display Available Frames:**
```dart
FrameShowcaseScreen.availableFrames.forEach((frame) {
  // Show frame preview
  // Display cost and rarity
  // Show lock/unlock status
});
```

2. **Handle Purchase:**
```dart
ElevatedButton(
  onPressed: () {
    final success = provider.purchaseFrame(frameId, cost);
    // Show success/failure message
  },
  child: Text('Buy for $cost coins'),
);
```

3. **Handle Equip:**
```dart
ElevatedButton(
  onPressed: () {
    provider.equipAvatarFrame(frameId);
    // Frame automatically updates everywhere
  },
  child: Text('Equip'),
);
```

## Testing the System

### 1. View All Frames
Navigate to the Frame Showcase screen:
```dart
Navigator.of(context).pushNamed(AppRoutes.frameShowcase);
```

### 2. Test Purchase Flow
```dart
// Give user coins for testing
provider.addCoins(5000);

// Attempt purchase
provider.purchaseFrame('legendary_flames', 1500);
```

### 3. Test Equip Flow
```dart
// Equip different frames and observe real-time updates
provider.equipAvatarFrame('rank_diamond');
// Navigate between screens to see consistent display
```

### 4. Verify State Management
```dart
// Change frame in one screen
provider.equipAvatarFrame('premium_gold');

// Navigate to another screen
// Verify the new frame is displayed everywhere
```

## Performance Considerations

1. **Animation Controllers**: Only animated frames use `AnimationController`
2. **Cached Images**: `CachedNetworkImage` prevents repeated downloads
3. **Efficient Rebuilds**: Provider pattern ensures only necessary widgets rebuild
4. **Frame Lookup**: Map-based frame selection is O(1) operation

## Future Enhancements

1. **Custom Paint Frames**: More complex frames using `CustomPaint`
2. **Lottie/Rive Animations**: Rich animated frames from animation files
3. **Seasonal Events**: Time-limited frames for special events
4. **Achievement Frames**: Frames unlocked through achievements
5. **NFT Integration**: Unique frames tied to blockchain tokens
6. **Frame Combinations**: Stack multiple frame effects

## Code Examples

### Basic Usage
```dart
EquippableAvatarFrame(
  avatarUrl: userProfile.avatar,
  frameId: userProfile.avatarFrame,
  radius: 50,
  onTap: () => print('Avatar tapped!'),
)
```

### With Provider
```dart
Consumer<UserController>(
  builder: (context, controller, _) {
    final user = controller.currentUser;
    return EquippableAvatarFrame(
      avatarUrl: user.avatar,
      frameId: user.avatarFrame,
      radius: 40,
    );
  },
)
```

### Purchase and Equip
```dart
final provider = context.read<UserProfileProvider>();

// Purchase
if (provider.purchaseFrame('premium_gold', 500)) {
  // Auto-equip after purchase
  provider.equipAvatarFrame('premium_gold');
}
```

## Acceptance Criteria Status

✅ **Reusable EquippableAvatarFrame widget exists**
- Created at `lib/widgets/equippable_avatar_frame.dart`

✅ **Used on Home, Profile, Matching, and Single Game pages**
- ProfileScreen: ✓
- HomeScreen/GameScreen: ✓
- LobbyScreen: ✓
- MatchmakingScreen: ✓
- LeaderboardScreen: ✓

✅ **At least 3 distinct frame styles implemented**
- 11 frame styles implemented (Basic, Premium Gold, 5 Rank frames, 3 Event frames, Holographic)

✅ **Frame driven by avatarFrame field from user data**
- Uses `userProfile.avatarFrame`
- Supports `unlockedFrames` list

✅ **Changing avatarFrame updates all screens live**
- Implemented via Provider pattern
- All widgets listen to UserProfileProvider
- State changes trigger automatic rebuilds

## Conclusion

The equippable avatar frame system is fully implemented and integrated throughout the application. It provides a data-driven, reusable, and extensible foundation for avatar customization with support for purchases, unlocks, and real-time updates across all screens.
