import 'package:flutter/material.dart';
import 'package:yes_or_no/core/theme/app_theme.dart';
import 'package:yes_or_no/screens/splash_screen.dart';
import 'package:yes_or_no/screens/home_screen.dart';
import 'package:yes_or_no/screens/lobby_screen.dart';
import 'package:yes_or_no/screens/game_room_screen.dart';
import 'package:yes_or_no/screens/placeholder_screens.dart';

void main() {
  runApp(const YesOrNoApp());
}

class YesOrNoApp extends StatelessWidget {
  const YesOrNoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yes Or No',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return _buildRoute(const SplashScreen());

      case '/home':
        return _buildRoute(const HomeScreen());

      case '/lobby':
        final roomCode = settings.arguments as String?;
        return _buildRoute(LobbyScreen(roomCode: roomCode));

      case '/game':
        return _buildRoute(const GameRoomScreen());

      case '/leaderboard':
        return _buildRoute(const LeaderboardScreen());

      case '/store':
        return _buildRoute(const StoreScreen());

      case '/settings':
        return _buildRoute(const SettingsScreen());

      default:
        return _buildRoute(const HomeScreen());
    }
  }

  MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }
}
