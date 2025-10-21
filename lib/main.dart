import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/di/service_locator.dart';
import 'controllers/user_controller.dart';
import 'controllers/game_controller.dart';
import 'providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please configure Firebase by following these steps:');
    debugPrint('1. Go to https://console.firebase.google.com');
    debugPrint('2. Select your project');
    debugPrint('3. Add iOS/Android app and download config files');
    debugPrint('4. Place google-services.json in android/app/');
    debugPrint('5. Place GoogleService-Info.plist in ios/Runner/');
    // Continue without Firebase for development
  }
  
  // Initialize dependency injection
  await serviceLocator.init();
  
  runApp(const YesOrNoApp());
}

class YesOrNoApp extends StatelessWidget {
  const YesOrNoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(),
        ),
        // Controllers
        ChangeNotifierProvider(
          create: (_) => UserController(serviceLocator.userService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => GameController(serviceLocator.gameService)..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Yes Or No',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        navigatorKey: serviceLocator.navigationService.navigatorKey,
        initialRoute: AppRoutes.initial, // ALWAYS start with Splash for security verification
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
