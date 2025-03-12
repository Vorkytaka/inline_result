part of 'result.dart';

/// Extension providing side-effect methods for [Result].
extension ResultOnActions<T> on Result<T> {
  /// Executes [action] if this Result is a failure and returns itself.
  ///
  /// Useful for logging or handling failures without modifying the Result.
  Result<T> onFailure(void Function(Exception exception) action) {
    final exc = exceptionOrNull;
    if (exc != null) {
      action(exc);
    }
    return this;
  }

  /// Executes [action] if this Result is successful and returns itself.
  ///
  /// Useful for processing successful values without modifying the Result.
  Result<T> onSuccess(void Function(T value) action) {
    if (isSuccess) {
      action(getOrThrow);
    }
    return this;
  }
}
