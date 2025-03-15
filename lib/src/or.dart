part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<R, T extends R> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  R getOrElse(FailureTransformer<R> onFailure) => _value is _Failure
      ? onFailure(_value.exception, _value.stacktrace)
      : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  R getOrDefault(R defaultValue) => isFailure ? defaultValue : _value as T;
}

/// Extension providing fallback value methods.
extension FutureResultOr<T extends R, R> on Future<Result<T>> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  Future<R> getOrElse(FailureTransformer<R> onFailure) =>
      then((result) => result.getOrElse(onFailure));

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  Future<R> getOrDefault(R defaultValue) =>
      then((result) => result.getOrDefault(defaultValue));
}
