# Yes Or No - Flutter Game

<div align="center">
  <h1>🎮 Y/N - Yes Or No Game</h1>
  <p><strong>A futuristic 1v1 deduction game built with Flutter</strong></p>
  <p>Compete to identify a secret word through strategic yes/no questions</p>
</div>

---

## 📋 Overview

**Yes Or No** is a mobile-first, real-time competitive deduction game where two players face off to discover a secret word by asking strategic yes/no questions. The faster you guess correctly, the higher your bounty reward!

### ✨ Features

- 🎨 **Futuristic Design**: Glassmorphism UI with neon cyan, magenta, and gold accents
- ⚡ **Quick Match**: Jump into a game instantly
- 🔒 **Private Rooms**: Create or join rooms with custom codes
- ⏱️ **Dynamic Timer**: 10-second countdown with color transitions
- 💰 **Bounty System**: Decreasing point rewards for strategic play
- 📊 **XP & Ranking**: Level progression system
- 📱 **Cross-Platform**: Single codebase for iOS and Android

### 🎯 Current Status: **PROTOTYPE MODE**

This is a **UI/UX prototype** with fully functional navigation and visual effects. Game logic returns debug prints only - perfect for demonstrating the design and user flows.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (included with Flutter)
- iOS: Xcode 13.0+ and iOS 12.0+ device/simulator
- Android: Android Studio and API level 21+ device/emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/YesOrNo-Flutter.git
   cd YesOrNo-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

---

## 📂 Project Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart          # Color palette
│       ├── app_text_styles.dart     # Typography
│       └── app_theme.dart           # Theme configuration
├── models/
│   ├── user_profile.dart            # User data model
│   ├── game_session.dart            # Game state model
│   ├── question_object.dart         # Question/answer model
│   └── match_result.dart            # Match outcome model
├── providers/
│   ├── user_profile_provider.dart   # User state management
│   └── game_state_provider.dart     # Game state management
├── screens/
│   ├── splash_screen.dart           # Launch screen
│   ├── home_screen.dart             # Main menu
│   ├── lobby_screen.dart            # Private room waiting
│   ├── game_room_screen.dart        # Gameplay interface
│   └── placeholder_screens.dart     # Leaderboard, Store, Settings
├── widgets/
│   ├── custom_button.dart           # Reusable button component
│   ├── avatar_widget.dart           # Player avatar display
│   ├── progress_bar_widget.dart     # XP progress bar
│   ├── question_card_widget.dart    # Question display card
│   ├── circular_timer_widget.dart   # Countdown timer
│   └── glass_container.dart         # Glassmorphism container
└── main.dart                        # App entry point
```

---

## 🎮 Game Flow

### 1. Splash Screen
- Auto-navigates to Home after 3 seconds
- Features animated logo with gradient and glow effects

### 2. Home Screen
- Profile header with avatar, rank badge, and XP bar
- **Quick Match**: Instant gameplay
- **Private Room**: Create or join with code
- Bottom navigation: Leaderboard, Profile, Store, Settings

### 3. Private Room Flow
- **Create**: Generates 5-character room code (e.g., KRTN5)
- **Join**: Enter code to join existing room
- Copy/share room code functionality
- Lobby shows player slots with waiting animation

### 4. Game Room
- **Bounty Bar**: Starting at 100 PTS, decreases over time
- **Split View**: Player zones (top and bottom)
- **Central Timer**: 10-second countdown with color transitions:
  - Cyan (>5s)
  - Yellow (3-5s)
  - Red (<3s)
- **Question Input**: Ask yes/no questions
- **Answer Feedback**: Green border for YES, red for NO
- **Final Guess**: Gold button to make your guess

### 5. Game Over
- Victory/defeat display with gradient text
- Secret word reveal
- Points awarded/deducted
- Options: Play Again or Back to Menu

---

## 🎨 Design System

### Color Palette

| Purpose | Hex Code | Usage |
|---------|----------|-------|
| Primary Cyan | `#00FFFF` | Primary actions, timer, player 1 |
| Secondary Magenta | `#FF00FF` | Private room, secondary actions |
| Tertiary Gold | `#FFD700` | Guess button, victory, rewards |
| YES Green | `#00FF7F` | Affirmative answers |
| NO Red | `#FF4136` | Negative answers |
| Background Dark | `#0A192F` | Main background |
| Glass Panel | `rgba(20,20,30,0.7)` | Glassmorphism overlays |

### Typography

- **Body**: Poppins 400, 16px
- **Headings**: Poppins 600-700, 22-48px
- **Timer**: Orbitron 700, 32-48px
- **Buttons**: Poppins 700, 16-20px

### Visual Effects

- **Glassmorphism**: Blur backdrop with semi-transparent panels
- **Glow Animations**: Pulsing effects on buttons and timer
- **Color Transitions**: Smooth state changes for feedback
- **Gradient Backgrounds**: Multi-layer depth

---

## 🔧 Technical Stack

### Core Technologies
- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider pattern
- **Navigation**: Flutter Navigator 2.0

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1                  # State management
  google_fonts: ^6.1.0              # Typography
  flutter_svg: ^2.0.9               # SVG assets
  cached_network_image: ^3.3.0      # Image caching
```

---

## 🧪 Prototype Features

The current implementation includes:

✅ **Fully Functional UI/UX**
- All screens navigable
- Smooth transitions and animations
- Complete visual design system

✅ **Debug Output**
- Button presses logged to console
- Navigation events tracked
- State changes printed

✅ **Mock Data**
- Sample user profiles
- Simulated questions/answers
- Random win/loss outcomes

❌ **Not Yet Implemented**
- Real-time multiplayer (Firebase)
- User authentication
- Persistent data storage
- Server-side game logic
- Leaderboard data
- In-app purchases

---

## 📱 Platform Support

### iOS
- **Minimum**: iOS 12.0
- **Devices**: iPhone 6s and later
- **Features**: SafeArea, Cupertino adaptations

### Android
- **Minimum**: API Level 21 (Android 5.0)
- **Target**: API Level 33+ (Android 13+)
- **Features**: Material Design, ripple effects

---

## 🔮 Future Roadmap

### Phase 1: Real-Time Multiplayer
- [ ] Firebase integration
- [ ] User authentication
- [ ] Firestore real-time sync
- [ ] Matchmaking system

### Phase 2: Game Logic
- [ ] AI referee for answer validation
- [ ] Secret word database
- [ ] Question filtering (NLP)
- [ ] Turn-based mechanics

### Phase 3: Progression
- [ ] XP calculation
- [ ] Rank advancement
- [ ] Achievement system
- [ ] Match history

### Phase 4: Social Features
- [ ] Friends list
- [ ] Chat system
- [ ] Leaderboards
- [ ] Replays

### Phase 5: Monetization
- [ ] Cosmetic store
- [ ] Avatar customization
- [ ] Premium features
- [ ] Ad integration

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Credits

- **Design Inspiration**: Futuristic glassmorphism and neon aesthetics
- **Fonts**: Google Fonts (Poppins, Space Grotesk, Orbitron)
- **Framework**: Flutter by Google

---

## 📧 Contact

For questions, suggestions, or feedback:
- **Email**: contact@yesornogame.com
- **Twitter**: @YesOrNoGame
- **Discord**: [Join our community](#)

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>© 2024 Yes Or No Game. All rights reserved.</p>
</div>
