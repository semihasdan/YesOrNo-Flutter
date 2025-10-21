# Quick Start Guide - OOP Architecture

## 🚀 Getting Started

This guide will help you understand and work with the new OOP-compliant architecture.

## 📋 Prerequisites

- Flutter SDK installed
- Dart 3.9.2 or higher
- IDE with Flutter support (VS Code, Android Studio, IntelliJ)

## 🏃 Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

## 🏗️ Architecture Quick Reference

### Layer Overview

```
┌────────────────────────────────────────────────┐
│  UI Layer (Screens & Widgets)                  │
│  - Displays data                               │
│  - Handles user interaction                    │
└─────────────────┬──────────────────────────────┘
                  │
                  ↓
┌────────────────────────────────────────────────┐
│  Controller Layer                              │
│  - UserController                              │
│  - GameController                              │
│  - Manages UI state (loading, error, data)     │
└─────────────────┬──────────────────────────────┘
                  │
                  ↓
┌────────────────────────────────────────────────┐
│  Service Layer                                 │
│  - UserService                                 │
│  - GameService                                 │
│  - Business logic & validation                 │
└─────────────────┬──────────────────────────────┘
                  │
                  ↓
┌────────────────────────────────────────────────┐
│  Repository Layer                              │
│  - UserRepository                              │
│  - GameRepository                              │
│  - Data access & CRUD operations               │
└─────────────────┬──────────────────────────────┘
                  │
                  ↓
┌────────────────────────────────────────────────┐
│  Data Sources                                  │
│  - Mock Data (currently)                       │
│  - Future: API, Database, Cache                │
└────────────────────────────────────────────────┘
```

## 📝 Common Tasks

### 1. Adding a New Screen

#### Step 1: Create the screen widget
```dart
// lib/screens/my_new_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (controller.hasError) {
          return Center(child: Text('Error: ${controller.error}'));
        }
        
        return Scaffold(
          appBar: AppBar(title: Text('My New Screen')),
          body: Center(
            child: Text('Hello, ${controller.currentUser?.username}!'),
          ),
        );
      },
    );
  }
}
```

#### Step 2: Add route
```dart
// lib/core/routes/app_routes.dart
class AppRoutes {
  // ... existing routes
  static const String myNewScreen = '/my-new-screen';
}
```

#### Step 3: Register route
```dart
// lib/core/routes/route_generator.dart
static Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ... existing cases
    case AppRoutes.myNewScreen:
      return _buildRoute(const MyNewScreen());
    // ...
  }
}
```

#### Step 4: Navigate to it
```dart
Navigator.of(context).pushNamed(AppRoutes.myNewScreen);
// or
serviceLocator.navigationService.navigateTo(AppRoutes.myNewScreen);
```

### 2. Adding Business Logic

#### Step 1: Add method to service
```dart
// lib/services/user_service.dart
class UserService implements BaseService {
  // ... existing code
  
  /// New business logic method
  Future<Result<void>> performAction() async {
    try {
      // Validate input
      // Perform business logic
      // Call repository
      final result = await _userRepository.doSomething();
      return Success(result);
    } catch (e) {
      return Failure('Failed to perform action: $e');
    }
  }
}
```

#### Step 2: Add controller method
```dart
// lib/controllers/user_controller.dart
class UserController extends BaseController {
  // ... existing code
  
  Future<bool> performAction() async {
    setLoading(true);
    clearError();
    
    try {
      final result = await _userService.performAction();
      
      if (result.isSuccess) {
        notifyListeners();
        return true;
      } else {
        setError(result.errorOrNull);
        return false;
      }
    } finally {
      setLoading(false);
    }
  }
}
```

#### Step 3: Use in UI
```dart
ElevatedButton(
  onPressed: () async {
    final controller = context.read<UserController>();
    final success = await controller.performAction();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action completed!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${controller.error}')),
      );
    }
  },
  child: Text('Perform Action'),
)
```

### 3. Adding Data Persistence

#### Step 1: Update repository
```dart
// lib/data/repositories/user_repository.dart
class UserRepository implements BaseRepository<UserProfile> {
  // Add your data source (API client, database, etc.)
  final ApiClient _apiClient;
  
  UserRepository(this._apiClient);
  
  @override
  Future<UserProfile?> getById(String id) async {
    // Instead of mock data:
    final response = await _apiClient.get('/users/$id');
    return UserProfile.fromJson(response.data);
  }
  
  // ... other methods
}
```

#### Step 2: Update service locator
```dart
// lib/core/di/service_locator.dart
class ServiceLocator {
  late final ApiClient _apiClient;
  
  Future<void> init() async {
    // Initialize API client
    _apiClient = ApiClient(baseUrl: 'https://api.example.com');
    
    // Initialize repositories with real data source
    _userRepository = UserRepository(_apiClient);
    
    // ... rest of initialization
  }
}
```

### 4. Validating User Input

```dart
// Use built-in validators
import '../core/utils/validators.dart';

// In your form
TextFormField(
  validator: Validators.validateUsername,
  decoration: InputDecoration(labelText: 'Username'),
)

// Or validate programmatically
final error = Validators.validateUsername(username);
if (error != null) {
  // Show error
  print(error);
}

// Add custom validator
// lib/core/utils/validators.dart
static String? validateCustomField(String? value) {
  if (value == null || value.isEmpty) {
    return 'Field cannot be empty';
  }
  // Add your validation logic
  return null;
}
```

### 5. Handling Errors

#### Using Result Pattern
```dart
// In service/controller
final result = await userService.getCurrentUser();

result
  .onSuccess((user) {
    // Handle success
    print('User: ${user.username}');
  })
  .onFailure((error) {
    // Handle error
    print('Error: $error');
  });

// Or with if/else
if (result.isSuccess) {
  final user = result.dataOrNull!;
  // Use user
} else {
  final error = result.errorOrNull!;
  // Show error
}
```

#### Controller Error State
```dart
// Controllers automatically manage error state
Consumer<UserController>(
  builder: (context, controller, child) {
    if (controller.hasError) {
      return ErrorWidget(controller.error!);
    }
    // ... normal UI
  },
)
```

## 🔍 Accessing Services

### Via Service Locator
```dart
import '../core/di/service_locator.dart';

// Get services
final userService = serviceLocator.userService;
final gameService = serviceLocator.gameService;
final navigationService = serviceLocator.navigationService;
```

### Via Controllers (Recommended)
```dart
import 'package:provider/provider.dart';

// In StatelessWidget
Widget build(BuildContext context) {
  final userController = context.watch<UserController>();
  // or
  final userController = Provider.of<UserController>(context);
  
  // Use controller
  final user = userController.currentUser;
}

// For one-time read (no rebuild on change)
final userController = context.read<UserController>();
```

## 🧪 Testing

### Unit Test Example
```dart
// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('UserService', () {
    late MockUserRepository mockRepo;
    late UserService userService;
    
    setUp(() {
      mockRepo = MockUserRepository();
      userService = UserService(mockRepo);
    });
    
    test('getCurrentUser returns user on success', () async {
      // Arrange
      final mockUser = UserProfile.mock();
      when(mockRepo.getCurrentUser())
        .thenAnswer((_) async => mockUser);
      
      // Act
      final result = await userService.getCurrentUser();
      
      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull, mockUser);
    });
    
    test('getCurrentUser returns failure on error', () async {
      // Arrange
      when(mockRepo.getCurrentUser())
        .thenThrow(Exception('Network error'));
      
      // Act
      final result = await userService.getCurrentUser();
      
      // Assert
      expect(result.isFailure, true);
      expect(result.errorOrNull, contains('Failed to get user'));
    });
  });
}
```

## 📚 Key Files Reference

### Configuration
- `lib/main.dart` - App entry point, DI setup
- `lib/core/di/service_locator.dart` - Dependency injection
- `lib/core/routes/app_routes.dart` - Route constants
- `lib/core/routes/route_generator.dart` - Route generation

### Business Logic
- `lib/services/user_service.dart` - User business logic
- `lib/services/game_service.dart` - Game business logic
- `lib/controllers/user_controller.dart` - User UI state
- `lib/controllers/game_controller.dart` - Game UI state

### Data Access
- `lib/data/repositories/user_repository.dart` - User data CRUD
- `lib/data/repositories/game_repository.dart` - Game data CRUD

### Utilities
- `lib/core/utils/result.dart` - Error handling
- `lib/core/utils/validators.dart` - Input validation

## 💡 Best Practices

1. **Always use dependency injection** - Don't create dependencies directly
   ```dart
   // ❌ BAD
   final service = UserService(UserRepository());
   
   // ✅ GOOD
   final service = serviceLocator.userService;
   ```

2. **Use Result pattern for errors** - Don't throw exceptions
   ```dart
   // ❌ BAD
   throw Exception('User not found');
   
   // ✅ GOOD
   return Failure('User not found');
   ```

3. **Keep controllers thin** - Move logic to services
   ```dart
   // ❌ BAD - Business logic in controller
   Future<void> addXP(int amount) async {
     final newXP = _user.xp + amount;
     if (newXP >= _user.xpMax) {
       // level up logic...
     }
   }
   
   // ✅ GOOD - Delegate to service
   Future<void> addXP(int amount) async {
     final result = await _userService.addXP(userId, amount);
     // Handle result...
   }
   ```

4. **Validate at the right layer**
   - UI validation: Basic format checks
   - Controller validation: Input validators
   - Service validation: Business rules
   - Repository validation: Data constraints

5. **Use const constructors** - Improve performance
   ```dart
   const MyWidget({Key? key}) : super(key: key);
   ```

## 🐛 Troubleshooting

### "Service not initialized"
```dart
// Make sure you await initialization in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await serviceLocator.init(); // ← Important!
  runApp(const YesOrNoApp());
}
```

### "Provider not found"
```dart
// Make sure the widget is wrapped in Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserController(...)),
  ],
  child: MyApp(),
)
```

### "Result extensions not working"
```dart
// Import the result file
import '../core/utils/result.dart';
```

## 📖 Further Reading

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture documentation
- [OOP_REFACTORING_SUMMARY.md](OOP_REFACTORING_SUMMARY.md) - Refactoring details
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)

---

**Need Help?** Contact: semih.asdan@gmail.com
