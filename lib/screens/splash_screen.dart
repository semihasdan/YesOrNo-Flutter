
import 'package:flutter/material.dart';
import 'dart:async';
import '../core/di/service_locator.dart';
import '../core/routes/app_routes.dart';
import '../widgets/spinning_logo_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay to show splash screen and logo animation
    await Future.delayed(const Duration(seconds: 2));

    // Get auth service from service locator
    final authService = serviceLocator.authService;
    
    // Verify user session with Firebase
    // This checks:
    // 1. If user is authenticated locally
    // 2. If the Firebase account still exists (not deleted)
    // 3. Cleans up invalid sessions automatically
    final bool isUserValid = await authService.verifyCurrentUser();

    if (!mounted) return;

    if (isUserValid) {
      // User is authenticated and verified - go to home
      debugPrint('Splash: User verified, navigating to Home');
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // No valid user session - show welcome/login screen
      debugPrint('Splash: No valid user, navigating to Welcome');
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Match app theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo (if you have one)
            // Image.asset('assets/logo1.png', width: 200),
            // const SizedBox(height: 48),
            
            // Animated loading indicator
            const SpinningLogoLoader(size: 120),
            
            const SizedBox(height: 32),
            
            // App name or tagline
            const Text(
              'Yes Or No',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
