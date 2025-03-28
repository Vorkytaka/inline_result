part of 'result.dart';

/// Extension providing side-effect methods for [Result].
extension ResultOnActions<T> on Result<T> {
  /// Executes [action] if this Result is a failure and returns itself.
  ///
  /// Useful for logging or handling failures without modifying the Result.
  @pragma('vm:prefer-inline')
  Result<T> onFailure<E extends Exception>(FailureTransformer<void, E> action) {
    if (_value is _Failure && _value.exception is E) {
      action(_value.exception as E, _value.stacktrace);
    }
    return this;
  }

  /// Executes [action] if this Result is successful and returns itself.
  ///
  /// Useful for processing successful values without modifying the Result.
  @pragma('vm:prefer-inline')
  Result<T> onSuccess(Transformer<T, void> action) {
    if (_value is T) {
      action(_value);
    }
    return this;
  }
}

extension FutureResultOnActions<T> on Future<Result<T>> {
  /// Executes [action] if this Result is a failure and returns itself.
  ///
  /// Useful for logging or handling failures without modifying the Result.
  @pragma('vm:prefer-inline')
  Future<Result<T>> onFailure<E extends Exception>(
          FailureTransformer<void, E> action) =>
      then((result) => result.onFailure<E>(action));

  /// Executes [action] if this Result is successful and returns itself.
  ///
  /// Useful for processing successful values without modifying the Result.
  @pragma('vm:prefer-inline')
  Future<Result<T>> onSuccess(void Function(T value) action) =>
      then((result) => result.onSuccess(action));
}
