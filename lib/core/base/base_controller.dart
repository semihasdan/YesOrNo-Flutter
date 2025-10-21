import 'package:flutter/foundation.dart';

/// Base controller for managing UI state and business logic coordination
/// Extends ChangeNotifier for reactive state management
abstract class BaseController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Set error message
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Initialize controller
  Future<void> initialize();
  
  @override
  void dispose() {
    super.dispose();
  }
}
