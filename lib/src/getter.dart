part of 'result.dart';

/// Extension providing getters for Result's values
extension ResultGetter<T> on Result<T> {
  /// Returns the encapsulated value if successful, otherwise `null`.
  @pragma('vm:prefer-inline')
  T? get getOrNull => isFailure ? null : _value as T;

  /// Returns the encapsulated exception if failed, otherwise `null`.
  @pragma('vm:prefer-inline')
  Exception? get exceptionOrNull =>
      isFailure ? (_value as _Failure).exception : null;

  /// Returns the encapsulated stacktrace if failed and there is stacktrace,
  /// otherwise `null`.
  @pragma('vm:prefer-inline')
  StackTrace? get stacktraceOrNull =>
      _value is _Failure ? _value.stacktrace : null;

  /// Returns the encapsulated value if successful, otherwise throws the exception.
  ///
  /// Throws the encapsulated [Exception] if this Result is a failure.
  @pragma('vm:prefer-inline')
  T get getOrThrow => _value is _Failure ? throw _value.exception : _value as T;
}

/// Extension providing getters for Result's values
extension FutureResultGetter<T> on Future<Result<T>> {
  /// Returns the encapsulated value if successful, otherwise `null`.
  @pragma('vm:prefer-inline')
  Future<T?> get getOrNull => then((result) => result.getOrNull);

  /// Returns the encapsulated exception if failed, otherwise `null`.
  @pragma('vm:prefer-inline')
  Future<Exception?> get exceptionOrNull =>
      then((result) => result.exceptionOrNull);

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
}
