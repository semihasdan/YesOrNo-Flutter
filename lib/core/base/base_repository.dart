/// Base repository interface for data access layer
/// Follows Repository pattern for separation of concerns
abstract class BaseRepository<T> {
  /// Get entity by ID
  Future<T?> getById(String id);
  
  /// Get all entities
  Future<List<T>> getAll();
  
  /// Create new entity
  Future<T> create(T entity);
  
  /// Update existing entity
  Future<T> update(String id, T entity);
  
  /// Delete entity by ID
  Future<bool> delete(String id);
}
