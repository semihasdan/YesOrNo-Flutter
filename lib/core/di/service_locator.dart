import '../../data/repositories/game_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../services/auth_service.dart';
import '../../services/game_service.dart';
import '../../services/user_service.dart';
import '../../services/navigation_service.dart';

/// Service Locator for Dependency Injection
/// Implements Singleton pattern for service access
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  
  factory ServiceLocator() => _instance;
  
  ServiceLocator._internal();
  
  // Repositories
  late final UserRepository _userRepository;
  late final GameRepository _gameRepository;
  
  // Services
  late final AuthService _authService;
  late final UserService _userService;
  late final GameService _gameService;
  late final NavigationService _navigationService;
  
  /// Initialize all services
  Future<void> init() async {
    // Initialize repositories
    _userRepository = UserRepository();
    _gameRepository = GameRepository();
    
    // Initialize services
    _authService = AuthService();
    _userService = UserService(_userRepository, _authService);
    _gameService = GameService(_gameRepository);
    _navigationService = NavigationService();
    
    // Initialize services
    await _authService.initialize();
    await _userService.initialize();
    await _gameService.initialize();
  }
  
  /// Get user repository
  UserRepository get userRepository => _userRepository;
  
  /// Get game repository
  GameRepository get gameRepository => _gameRepository;
  
  /// Get auth service
  AuthService get authService => _authService;
  
  /// Get user service
  UserService get userService => _userService;
  
  /// Get game service
  GameService get gameService => _gameService;
  
  /// Get navigation service
  NavigationService get navigationService => _navigationService;
  
  /// Dispose all services
  void dispose() {
    _authService.dispose();
    _userService.dispose();
    _gameService.dispose();
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();
