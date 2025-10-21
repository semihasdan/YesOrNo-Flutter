import 'package:flutter/material.dart';

/// Navigation service for centralized routing
/// Provides type-safe navigation methods
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Get current context
  BuildContext? get context => navigatorKey.currentContext;
  
  /// Navigate to named route
  Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  }
  
  /// Navigate to named route and remove all previous routes
  Future<T?>? navigateAndRemoveAll<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// Navigate to named route and replace current
  Future<T?>? navigateAndReplace<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed<T?, T>(
      routeName,
      arguments: arguments,
    );
  }
  
  /// Go back
  void goBack<T>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }
  
  /// Check if can go back
  bool canGoBack() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
  
  /// Pop until route
  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(
      (route) => route.settings.name == routeName,
    );
  }
  
  /// Pop to first route
  void popToFirst() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
}
