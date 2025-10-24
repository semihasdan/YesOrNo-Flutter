import 'package:flutter/material.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/lobby_screen.dart';
import '../../screens/matchmaking_screen.dart';
import '../../screens/game_room_screen.dart';
import '../../screens/single_player_game_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/frame_showcase_screen.dart';
import '../../screens/placeholder_screens.dart' hide LeaderboardScreen;
import 'app_routes.dart';

/// Route generator for the application
/// Centralized route configuration with type-safe parameters
class RouteGenerator {
  /// Generate routes based on settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.welcome:
        return _buildRoute(const WelcomeScreen());

      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());

      case AppRoutes.home:
        return _buildRoute(const HomeScreen());

      case AppRoutes.lobby:
        final roomCode = settings.arguments as String?;
        return _buildRoute(LobbyScreen(roomCode: roomCode));

      case AppRoutes.matchmaking:
        return _buildRoute(const MatchmakingScreen());

      case AppRoutes.game:
        return _buildRoute(const GameRoomScreen());

      case AppRoutes.singlePlayer:
        return _buildRoute(const SinglePlayerGameScreen());

      case AppRoutes.leaderboard:
        return _buildRoute(const LeaderboardScreen());

      case AppRoutes.store:
        return _buildRoute(const StoreScreen());

      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen());

      case AppRoutes.frameShowcase:
        return _buildRoute(const FrameShowcaseScreen());

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /// Build a material page route
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
  
  /// Build a page route with custom transitions
  static PageRouteBuilder _buildRouteWithTransition(
    Widget screen, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
