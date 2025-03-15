part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<T extends R, R> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  R getOrElse(FailureTransformer<R> onFailure) => _value is _Failure
      ? onFailure(_value.exception, _value.stacktrace)
      : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  R getOrDefault(R defaultValue) => isFailure ? defaultValue : _value as T;
}
