part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<T extends R, R> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  R getOrElse(R Function(Exception exception) onFailure) {
    final exception = exceptionOrNull;
    return exception != null ? onFailure(exception) : _value as T;
  }

  /// Returns the value if successful, otherwise [defaultValue].
  R getOrDefault(R defaultValue) => isFailure ? defaultValue : _value as T;
}
