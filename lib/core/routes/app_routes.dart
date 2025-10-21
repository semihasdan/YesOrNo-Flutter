/// Application route names
/// Centralized route management for type-safe navigation
class AppRoutes {
  // Prevent instantiation
  AppRoutes._();
  
  /// Welcome/Login screen route (first screen)
  static const String welcome = '/welcome';
  
  /// Splash screen route
  static const String splash = '/splash';
  
  /// Home screen route
  static const String home = '/home';
  
  /// Lobby screen route
  static const String lobby = '/lobby';
  
  /// Matchmaking screen route
  static const String matchmaking = '/matchmaking';
  
  /// Game room screen route
  static const String game = '/game';
  
  /// Leaderboard screen route
  static const String leaderboard = '/leaderboard';
  
  /// Store screen route
  static const String store = '/store';
  
  /// Settings screen route
  static const String settings = '/settings';
  
  /// Initial route - ALWAYS start with splash for security verification
  static const String initial = splash;
}
