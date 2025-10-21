# Yes Or No - 1v1 Word Deduction Game

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)](LICENSE)

A futuristic 1v1 deduction game where players compete to identify a secret word through strategic yes/no questions. Built with **Clean Architecture** principles and **OOP best practices**.

## 🎮 About The Game

Yes Or No is a competitive word deduction game where two players face off in a battle of wits. One player thinks of a secret word, and the opponent must guess it by asking strategic yes/no questions. Each question decreases the bounty, adding pressure to make every question count!

### Key Features

- 🎯 **Quick Match** - Jump into instant 1v1 matches
- 🔒 **Private Rooms** - Create or join private games with friends
- ⏱️ **Real-time Timer** - 10-second countdown per question round
- 💰 **Bounty System** - Points decrease with each question
- 📊 **Progression System** - Earn XP, level up, and climb ranks
- 🎨 **Futuristic UI** - Glassmorphism design with neon accents
- 🏆 **Leaderboards** - Compete globally (coming soon)

## 🏗️ Architecture

This project implements **Clean Architecture** with strict adherence to **SOLID principles**:

### Architecture Layers

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)           │
│   - Screens & Widgets               │
├─────────────────────────────────────┤
│   Controller Layer                  │
│   - State Management (Provider)     │
├─────────────────────────────────────┤
│   Service Layer                     │
│   - Business Logic                  │
├─────────────────────────────────────┤
│   Repository Layer                  │
│   - Data Access & CRUD              │
├─────────────────────────────────────┤
│   Data Sources                      │
│   - API / Database / Mock           │
└─────────────────────────────────────┘
```

### Design Patterns Used

- ✅ **Repository Pattern** - Data access abstraction
- ✅ **Service Layer Pattern** - Business logic encapsulation
- ✅ **Result Pattern** - Type-safe error handling
- ✅ **Dependency Injection** - Service locator pattern
- ✅ **Controller Pattern** - MVVM-like state management
- ✅ **Observer Pattern** - Reactive state updates

### SOLID Principles

- ✅ **Single Responsibility** - Each class has one clear purpose
- ✅ **Open/Closed** - Open for extension, closed for modification
- ✅ **Liskov Substitution** - Implementations can replace interfaces
- ✅ **Interface Segregation** - Focused, minimal interfaces
- ✅ **Dependency Inversion** - Depend on abstractions, not concretions

## 📁 Project Structure

```
lib/
├── core/
│   ├── base/              # Base classes (Repository, Service, Controller)
│   ├── di/                # Dependency Injection (Service Locator)
│   ├── routes/            # Navigation (Routes, Route Generator)
│   ├── theme/             # Theming (Colors, Text Styles, Theme)
│   └── utils/             # Utilities (Result, Validators)
├── data/
│   └── repositories/      # Data access layer
├── models/                # Data models
├── services/              # Business logic layer
├── controllers/           # Presentation logic
├── screens/               # UI screens
├── widgets/               # Reusable components
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code / IntelliJ IDEA

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/yes_or_no.git
cd yes_or_no
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Running on Different Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Desktop (macOS)
flutter run -d macos
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

## 📦 Dependencies

### Production
- **provider** (^6.1.1) - State management
- **google_fonts** (^6.1.0) - Custom fonts
- **flutter_svg** (^2.0.9) - SVG support
- **cached_network_image** (^3.3.0) - Image caching

### Development
- **flutter_test** - Testing framework
- **flutter_lints** (^5.0.0) - Linting rules

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Comprehensive architecture documentation
- **[OOP_REFACTORING_SUMMARY.md](OOP_REFACTORING_SUMMARY.md)** - Refactoring details and patterns
- **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** - Quick start guide for developers

## 🎨 UI/UX Design

### Design System

- **Color Scheme**: Dark theme with cyan, magenta, and gold accents
- **Typography**: Poppins (primary), Space Grotesk, Orbitron (timers)
- **Design Style**: Glassmorphism with neon borders
- **Animations**: Smooth transitions and micro-interactions

### Screens

1. **Splash Screen** - Animated loading screen
2. **Home Screen** - Main menu with Quick Match and Private Room
3. **Lobby Screen** - Waiting room for private matches
4. **Game Room** - Active gameplay screen
5. **Leaderboard** - Player rankings (coming soon)
6. **Store** - In-app purchases (coming soon)
7. **Settings** - App configuration (coming soon)

## 🔧 Development

### Adding a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/models/my_model.dart
   class MyModel {
     final String id;
     final String name;
     // ... implement toJson, fromJson, copyWith
   }
   ```

2. **Create Repository**
   ```dart
   // lib/data/repositories/my_repository.dart
   class MyRepository implements BaseRepository<MyModel> {
     // Implement CRUD operations
   }
   ```

3. **Create Service**
   ```dart
   // lib/services/my_service.dart
   class MyService implements BaseService {
     final MyRepository _repository;
     // Implement business logic
   }
   ```

4. **Create Controller**
   ```dart
   // lib/controllers/my_controller.dart
   class MyController extends BaseController {
     final MyService _service;
     // Implement UI state management
   }
   ```

5. **Register in Service Locator**
6. **Create UI Screen**
7. **Add Route**

See [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) for detailed examples.

## 🎯 Roadmap

### Phase 1 (Current) - Core Gameplay ✅
- [x] Basic UI/UX
- [x] Clean Architecture implementation
- [x] OOP refactoring
- [x] Mock gameplay logic

### Phase 2 - Backend Integration 🚧
- [ ] API integration
- [ ] Real-time multiplayer (WebSocket)
- [ ] User authentication
- [ ] Data persistence

### Phase 3 - Enhanced Features 📋
- [ ] Leaderboards
- [ ] In-app store
- [ ] Achievement system
- [ ] Social features (friends, chat)
- [ ] Analytics integration

### Phase 4 - Polish & Release 🚀
- [ ] Performance optimization
- [ ] Extensive testing
- [ ] App store deployment
- [ ] Marketing materials

## 🤝 Contributing

This is a private project. Contributions are currently not accepted.

## 📄 License

This project is private and proprietary. All rights reserved.

## 👨‍💻 Author

**Semih Aşdan**  
📧 Email: semih.asdan@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- Google Fonts for typography
- Design inspiration from futuristic UI trends

---

**Last Updated**: 2025-10-20  
**Version**: 1.0.0  
**Status**: In Development 🚧
