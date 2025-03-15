part of 'result.dart';

/// Extension providing side-effect methods for [Result].
extension ResultOnActions<T> on Result<T> {
  /// Executes [action] if this Result is a failure and returns itself.
  ///
  /// Useful for logging or handling failures without modifying the Result.
  @pragma('vm:prefer-inline')
  Result<T> onFailure(FailureTransformer<void> action) {
    if (_value is _Failure) {
      action(_value.exception, _value.stacktrace);
    }
    return this;
  }

  /// Executes [action] if this Result is successful and returns itself.
  ///
  /// Useful for processing successful values without modifying the Result.
  @pragma('vm:prefer-inline')
  Result<T> onSuccess(void Function(T value) action) {
    if (_value is T) {
      action(_value);
    }
    return this;
  }
}
