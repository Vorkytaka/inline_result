part of 'result.dart';

/// Extension providing getters for Result's values
extension ResultGetter<T, F extends Object> on Result<T, F> {
  /// Returns the encapsulated value if successful, otherwise `null`.
  @pragma('vm:prefer-inline')
  T? get getOrNull => isFailure ? null : _value as T;

  /// Returns the encapsulated exception if failed, otherwise `null`.
  @pragma('vm:prefer-inline')
  F? get exceptionOrNull => _value is _Failure<F> ? _value.exception : null;

  /// Returns the encapsulated stacktrace if failed and there is stacktrace,
  /// otherwise `null`.
  @pragma('vm:prefer-inline')
  StackTrace? get stacktraceOrNull =>
      _value is _Failure<F> ? _value.stacktrace : null;

  /// Returns the encapsulated value if successful, otherwise throws the exception.
  ///
  /// Throws the encapsulated [Exception] if this Result is a failure.
  @pragma('vm:prefer-inline')
  T get getOrThrow =>
      //ignore:only_throw_errors
      _value is _Failure<F> ? throw _value.exception : _value as T;

  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  T getOrElse(FailureTransformer<T, F> onFailure) => _value is _Failure<F>
      ? onFailure(_value.exception, _value.stacktrace)
      : _value as T;

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  T getOrDefault(T defaultValue) =>
      _value is _Failure<F> ? defaultValue : _value as T;
}

/// Extension providing getters for Result's values
extension FutureResultGetter<T, F extends Object> on Future<Result<T, F>> {
  /// Returns the encapsulated value if successful, otherwise `null`.
  @pragma('vm:prefer-inline')
  Future<T?> get getOrNull => then((result) => result.getOrNull);

  /// Returns the encapsulated exception if failed, otherwise `null`.
  @pragma('vm:prefer-inline')
  Future<F?> get exceptionOrNull => then((result) => result.exceptionOrNull);

  /// Returns the encapsulated stacktrace if failed and there is stacktrace,
  /// otherwise `null`.
  @pragma('vm:prefer-inline')
  Future<StackTrace?> get stacktraceOrNull =>
      then((result) => result.stacktraceOrNull);

  /// Returns the encapsulated value if successful, otherwise throws the exception.
  ///
  /// Throws the encapsulated [Exception] if this Result is a failure.
  @pragma('vm:prefer-inline')
  Future<T> get getOrThrow => then((result) => result.getOrThrow);

  /// Returns the value if successful, otherwise applies [onFailure].
  @pragma('vm:prefer-inline')
  Future<T> getOrElse(AsyncFailureTransformer<T, F> onFailure) =>
      then((result) => result._value is _Failure<F>
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
