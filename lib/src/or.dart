part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<T> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  T getOrElse<E extends Exception>(FailureTransformer<T, E> onFailure) =>
      _value is _Failure && _value.exception is E
          ? onFailure(_value.exception as E, _value.stacktrace)
          : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  T getOrDefault<E extends Exception>(T defaultValue) =>
      _value is _Failure && _value.exception is E ? defaultValue : _value as T;
}

/// Extension providing fallback value methods.
extension FutureResultOr<T> on Future<Result<T>> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  Future<T> getOrElse<E extends Exception>(
          FailureTransformer<T, E> onFailure) =>
      then((result) => result.getOrElse<E>(onFailure));

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  Future<T> getOrDefault<E extends Exception>(T defaultValue) =>
      then((result) => result.getOrDefault<E>(defaultValue));
}
