part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<T> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  T getOrElse(FailureTransformer<T> onFailure) => _value is _Failure
      ? onFailure(_value.exception, _value.stacktrace)
      : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  T getOrDefault(T defaultValue) => isFailure ? defaultValue : _value as T;
}

/// Extension providing fallback value methods.
extension FutureResultOr<T> on Future<Result<T>> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  Future<T> getOrElse(FailureTransformer<T> onFailure) =>
      then((result) => result.getOrElse(onFailure));

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  Future<T> getOrDefault(T defaultValue) =>
      then((result) => result.getOrDefault(defaultValue));
}
