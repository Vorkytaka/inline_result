part of 'result.dart';

/// Extension providing fallback value methods.
extension ResultOr<T> on Result<T> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  T getOrElse(FailureTransformer<T, Exception> onFailure) => _value is _Failure
      ? onFailure(_value.exception, _value.stacktrace)
      : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  T getOrDefault(T defaultValue) =>
      _value is _Failure ? defaultValue : _value as T;
}

/// Extension providing fallback value methods.
extension FutureResultOr<T> on Future<Result<T>> {
  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  Future<T> getOrElse(AsyncFailureTransformer<T, Exception> onFailure) =>
      then((result) => result._value is _Failure
          ? onFailure(
              result._value.exception,
              result._value.stacktrace,
            )
          : result._value as T);

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  Future<T> getOrDefault(T defaultValue) =>
      then((result) => result.getOrDefault(defaultValue));
}
