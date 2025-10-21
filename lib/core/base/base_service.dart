/// Base service interface for business logic layer
/// Encapsulates business rules and orchestrates data flow
abstract class BaseService {
  /// Initialize service (load initial data, setup listeners, etc.)
  Future<void> initialize();
  
  /// Dispose/cleanup resources
  void dispose();
}
