# Yes Or No - OOP Architecture Documentation

## 🏗️ Architecture Overview

This project follows a **Clean Architecture** pattern with clear separation of concerns, implementing industry-standard OOP principles for maintainability, scalability, and testability.

## 📁 Project Structure

```
lib/
├── core/                      # Core utilities and configurations
│   ├── base/                  # Base classes and interfaces
│   │   ├── base_controller.dart    # Base controller for state management
│   │   ├── base_repository.dart    # Repository interface
│   │   └── base_service.dart       # Service interface
│   ├── di/                    # Dependency Injection
│   │   └── service_locator.dart    # Service locator pattern
│   ├── routes/                # Navigation configuration
│   │   ├── app_routes.dart         # Route constants
│   │   └── route_generator.dart    # Route generation logic
│   ├── theme/                 # Theming
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── utils/                 # Utilities
│       ├── result.dart             # Result type for error handling
│       └── validators.dart         # Input validation utilities
├── data/                      # Data layer
│   └── repositories/          # Repository implementations
│       ├── game_repository.dart    # Game data operations
│       └── user_repository.dart    # User data operations
├── models/                    # Data models
│   ├── game_session.dart
│   ├── match_result.dart
│   ├── question_object.dart
│   └── user_profile.dart
├── services/                  # Business logic layer
│   ├── game_service.dart           # Game business logic
│   ├── navigation_service.dart     # Navigation abstraction
│   └── user_service.dart           # User business logic
├── controllers/               # Presentation logic
│   ├── game_controller.dart        # Game UI state management
│   └── user_controller.dart        # User UI state management
├── screens/                   # UI screens
├── widgets/                   # Reusable UI components
└── main.dart                  # Application entry point
```

## 🎯 Architecture Layers

### 1. **Presentation Layer** (UI)
- **Screens**: StatefulWidget/StatelessWidget components
- **Widgets**: Reusable UI components
- **Controllers**: Manage UI state using ChangeNotifier pattern

### 2. **Business Logic Layer** (Services)
- **Services**: Encapsulate business rules and orchestrate data flow
- **Implements**: BaseService interface for consistency
- **Responsibilities**: Validation, calculations, game logic

### 3. **Data Layer** (Repositories)
- **Repositories**: Abstract data access
- **Implements**: BaseRepository<T> interface
- **Responsibilities**: CRUD operations, data persistence

### 4. **Domain Layer** (Models)
- **Models**: Immutable data classes
- **Features**: JSON serialization, copyWith methods, factory constructors

## 🔑 Key Design Patterns

### 1. **Repository Pattern**
```dart
abstract class BaseRepository<T> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(String id, T entity);
  Future<bool> delete(String id);
}
```

**Benefits:**
- Abstraction over data sources
- Easy to swap implementations (mock, API, local storage)
- Testable

### 2. **Service Layer Pattern**
```dart
class UserService implements BaseService {
  final UserRepository _repository;
  
  Future<Result<UserProfile>> getCurrentUser() async {
    // Business logic here
  }
}
```

**Benefits:**
- Encapsulates business logic
- Reusable across different UI components
- Easier to test

### 3. **Dependency Injection (Service Locator)**
```dart
final serviceLocator = ServiceLocator();

void main() async {
  await serviceLocator.init();
  runApp(const YesOrNoApp());
}
```

**Benefits:**
- Centralized dependency management
- Easier testing with mock injection
- Loose coupling between components

### 4. **Result Pattern**
```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
}

class Failure<T> extends Result<T> {
  final String message;
}
```

**Benefits:**
- Type-safe error handling
- No try-catch spaghetti code
- Explicit success/failure states

### 5. **Controller Pattern (MVVM-like)**
```dart
class UserController extends BaseController {
  final UserService _userService;
  
  Future<void> initialize() async {
    setLoading(true);
    final result = await _userService.getCurrentUser();
    // Handle result
    setLoading(false);
  }
}
```

**Benefits:**
- Separation of presentation logic from UI
- Reactive state updates via ChangeNotifier
- Testable without UI

## 🔄 Data Flow

```
UI (Screens/Widgets)
    ↓ user action
Controllers (State Management)
    ↓ business operation
Services (Business Logic)
    ↓ data operation
Repositories (Data Access)
    ↓ CRUD
Data Sources (API/Database/Mock)
```

## 🧩 OOP Principles Applied

### 1. **Single Responsibility Principle (SRP)**
- Each class has one reason to change
- Controllers: UI state only
- Services: Business logic only
- Repositories: Data access only

### 2. **Open/Closed Principle (OCP)**
- Base classes are open for extension
- Implementations are closed for modification
- Example: BaseRepository<T> can be extended for any entity

### 3. **Liskov Substitution Principle (LSP)**
- Implementations can replace interfaces without breaking functionality
- All repositories implement BaseRepository<T>

### 4. **Interface Segregation Principle (ISP)**
- BaseService, BaseRepository, BaseController are focused interfaces
- No client depends on methods it doesn't use

### 5. **Dependency Inversion Principle (DIP)**
- High-level modules (Controllers) depend on abstractions (Services)
- Low-level modules (Repositories) depend on abstractions (BaseRepository)
- Both depend on interfaces, not concrete implementations

## 📋 Usage Examples

### Creating a New Feature

#### 1. Create Model
```dart
class MyModel {
  final String id;
  final String name;
  
  MyModel({required this.id, required this.name});
  
  MyModel copyWith({String? id, String? name}) { /* ... */ }
  
  Map<String, dynamic> toJson() { /* ... */ }
  
  factory MyModel.fromJson(Map<String, dynamic> json) { /* ... */ }
}
```

#### 2. Create Repository
```dart
class MyRepository implements BaseRepository<MyModel> {
  @override
  Future<MyModel?> getById(String id) async {
    // Implementation
  }
  // ... other methods
}
```

#### 3. Create Service
```dart
class MyService implements BaseService {
  final MyRepository _repository;
  
  MyService(this._repository);
  
  Future<Result<MyModel>> doSomething() async {
    // Business logic
  }
}
```

#### 4. Create Controller
```dart
class MyController extends BaseController {
  final MyService _service;
  
  MyController(this._service);
  
  @override
  Future<void> initialize() async { /* ... */ }
}
```

#### 5. Register in Service Locator
```dart
class ServiceLocator {
  late final MyRepository _myRepository;
  late final MyService _myService;
  
  Future<void> init() async {
    _myRepository = MyRepository();
    _myService = MyService(_myRepository);
  }
}
```

#### 6. Use in UI
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyController>(
      builder: (context, controller, child) {
        if (controller.isLoading) return LoadingWidget();
        if (controller.hasError) return ErrorWidget(controller.error);
        
        return /* Your UI */;
      },
    );
  }
}
```

## ✅ Benefits of This Architecture

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Clear structure makes code easy to navigate
3. **Scalability**: Easy to add new features following the same pattern
4. **Reusability**: Services and repositories can be reused across features
5. **Type Safety**: Strong typing with Dart's null safety
6. **Error Handling**: Consistent error handling via Result pattern
7. **Separation of Concerns**: UI, business logic, and data access are separated
8. **Dependency Injection**: Loose coupling enables easy mocking and testing

## 🧪 Testing Strategy

### Unit Tests
- Test services independently with mock repositories
- Test controllers with mock services
- Test validators and utilities

### Integration Tests
- Test service + repository integration
- Test controller + service integration

### Widget Tests
- Test UI components with mock controllers

## 📚 Best Practices

1. **Always use dependency injection** - Don't instantiate dependencies directly
2. **Use Result pattern** for operations that can fail
3. **Validate inputs** at the controller level using Validators
4. **Keep controllers thin** - Move logic to services
5. **Keep services testable** - Inject dependencies, don't create them
6. **Use immutable models** - Implement copyWith for updates
7. **Follow naming conventions** - Consistent naming across layers

## 🔍 Code Quality

- ✅ All files follow Dart style guide
- ✅ No business logic in UI components
- ✅ Proper error handling throughout
- ✅ Type-safe navigation with route constants
- ✅ Consistent code structure
- ✅ Documented public APIs
- ✅ Null safety compliance

---

**Author**: Semih Aşdan (semih.asdan@gmail.com)
**Last Updated**: 2025-10-20
