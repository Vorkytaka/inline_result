import 'dart:async';

import 'package:meta/meta.dart';

/// Transform success [value] into new value of [R].
typedef Transformer<T, R> = R Function(T value);

typedef AsyncTransformer<T, R> = FutureOr<R> Function(T value);

/// Transform failure result from [exception] and optional [stacktrace] into new value of [R].
typedef FailureTransformer<R, E extends Exception> = R Function(
  E exception,
  StackTrace? stacktrace,
);

typedef AsyncFailureTransformer<R, E extends Exception> = FutureOr<R> Function(
  E exception,
  StackTrace? stacktrace,
);

/// Execute block of code with given result of [T].
typedef Block<T> = T Function();

/// A discriminated union that encapsulates a successful outcome with a value of type [T]
/// or a failure with an [Exception].
///
/// This is implemented as an extension type for zero-cost wrapping, providing static type safety
/// while having no runtime overhead. Use [Result.success] to wrap successful values and
/// [Result.failure] to wrap exceptions.
extension type const Result<T>._(dynamic _value) {
  /// Creates a successful Result containing [value].
  const factory Result.success(T value) = Result._;

  /// Creates a failed Result containing [exception] and optional [stacktrace].
  factory Result.failure(Exception exception, [StackTrace? stacktrace]) =>
      Result._(_Failure(exception, stacktrace));

  /// Executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  @pragma('vm:prefer-inline')
  static Result<T> runCatching<T>(Block<T> block) {
    try {
      return Result.success(block());
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }

  /// Returns `true` if this [Result] is successful.
  bool get isSuccess => _value is! _Failure;

  /// Returns `true` if this [Result] is a failure.
  bool get isFailure => _value is _Failure;
}

@immutable
class _Failure {
  /// The exception encapsulated in this failure.
  final Exception exception;

  /// Optional stacktrace of this failure.
  final StackTrace? stacktrace;

  const _Failure(
    this.exception, [
    this.stacktrace,
  ]);

  @override
  String toString() {
    if (stacktrace != null) {
      return '_Failure($exception; $stacktrace)';
    }
    return '_Failure($exception)';
  }

  @override
  bool operator ==(Object other) =>
      other is _Failure &&
      exception == other.exception &&
      stacktrace == other.stacktrace;

  @override
  int get hashCode => Object.hash(exception, stacktrace);
}

/// Extension providing folding functionality for [Result].
extension ResultFold<T> on Result<T> {
  /// Combines both cases of Result into a single value.
  ///
  /// [onSuccess] handles successful values.
  /// [onFailure] handles exceptions.
  @pragma('vm:prefer-inline')
  R fold<R>({
    required Transformer<T, R> onSuccess,
    required FailureTransformer<R, Exception> onFailure,
  }) =>
      _value is _Failure
          ? onFailure(_value.exception, _value.stacktrace)
          : onSuccess(_value as T);
}

/// Extension providing folding functionality for [Result].
extension FutureResultFold<T> on Future<Result<T>> {
  /// Combines both cases of Result into a single value.
  ///
  /// [onSuccess] handles successful values.
  /// [onFailure] handles exceptions.
  @pragma('vm:prefer-inline')
  Future<R> fold<R>({
    required AsyncTransformer<T, R> onSuccess,
    required AsyncFailureTransformer<R, Exception> onFailure,
  }) =>
      then((result) => result._value is _Failure
          ? onFailure(result._value.exception, result._value.stacktrace)
          : onSuccess(result._value));
}

extension FutureResult<T> on Future<T> {
  /// Converts a [Future] into a [Result].
  ///
  /// - If the [Future] completes successfully, wraps the value in [Result.success].
  /// - If the [Future] completes with an [Exception], wraps the exception in [Result.failure].
  Future<Result<T>> get asResult =>
      then(Result.success).onError<Exception>(Result<T>.failure);
}

extension FutureOrResult<T> on FutureOr<T> {
  FutureOr<Result<T>> get asResult async {
    try {
      return Result.success(await this);
    } on Exception catch (e, st) {
      return Result.failure(e, st);
    }
  }
}

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
      then((result) => result._value is _Failure ? onFailure : result._value);

  /// Returns the value if successful, otherwise [defaultValue].
  @pragma('vm:prefer-inline')
  Future<T> getOrDefault(T defaultValue) =>
      then((result) => result.getOrDefault(defaultValue));
}

/// Extension providing recovery methods for [Result].
extension ResultRecover<T> on Result<T> {
  /// Transforms a failure into a success using [transform].
  ///
  /// If this [Result] is a failure, applies [transform] to the exception and returns
  /// a successful [Result] containing the transformed value.
  /// If successful, returns the original [Result].
  @pragma('vm:prefer-inline')
  Result<T> recover<E extends Exception>(FailureTransformer<T, E> transform) =>
      _value is _Failure && _value.exception is E
          ? Result.success(transform(_value.exception as E, _value.stacktrace))
          : this;

  /// Transforms a failure into a success, catching exceptions from [transform].
  ///
  /// Similar to [recover], but wraps any exceptions thrown by [transform] in a [Result].
  @pragma('vm:prefer-inline')
  Result<T> recoverCatching<E extends Exception>(
    FailureTransformer<T, E> transform,
  ) =>
      _value is _Failure && _value.exception is E
          ? runCatching(() => transform(
                _value.exception as E,
                _value.stacktrace,
              ))
          : this;
}

/// Extension providing recovery methods for [Result].
extension FutureResultRecover<T> on Future<Result<T>> {
  /// Transforms a failure into a success using [transform].
  ///
  /// If this [Result] is a failure, applies [transform] to the exception and returns
  /// a successful [Result] containing the transformed value.
  /// If successful, returns the original [Result].
  @pragma('vm:prefer-inline')
  Future<Result<T>> recover<E extends Exception>(
    AsyncFailureTransformer<T, E> transform,
  ) =>
      then((result) async =>
          result._value is _Failure && result._value.exception is E
              ? Result.success(await transform(
                  result._value.exception as E,
                  result._value.stacktrace,
                ))
              : result);

  /// Transforms a failure into a success, catching exceptions from [transform].
  ///
  /// Similar to [recover], but wraps any exceptions thrown by [transform] in a [Result].
  @pragma('vm:prefer-inline')
  Future<Result<T>> recoverCatching<E extends Exception>(
          AsyncFailureTransformer<T, E> transform) =>
      then((result) => result._value is _Failure && result._value.exception is E
          ? transform(
              result._value.exception as E,
              result._value.stacktrace,
            ).asResult
          : result);
}

/// Executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
@pragma('vm:prefer-inline')
Result<T> runCatching<T>(Block<T> block) {
  try {
    return Result.success(block());
  } on Exception catch (exception, stacktrace) {
    return Result.failure(exception, stacktrace);
  }
}

/// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
Future<Result<T>> asyncRunCatching<T>(Future<T> Function() block) async {
  try {
    return Result.success(await block());
  } on Exception catch (exception, stacktrace) {
    return Result.failure(exception, stacktrace);
  }
}

/// Extension providing runCatching method for any value.
extension RunCatchingX<T> on T {
  /// Executes [block] with current value as input
  /// and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  @pragma('vm:prefer-inline')
  Result<R> runCatching<R>(R Function(T value) block) {
    try {
      return Result.success(block(this));
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }

  /// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  Future<Result<R>> asyncRunCatching<R>(
    Future<R> Function(T value) block,
  ) async {
    try {
      return Result.success(await block(this));
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }
}

/// Extension providing transformation methods for [Result].
extension ResultTransformation<T> on Result<T> {
  /// Transforms a successful value using [transform].
  ///
  /// If successful, returns a new Result with the transformed value.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Result<R> map<R>(Transformer<T, R> transform) =>
      isSuccess ? Result.success(transform(_value as T)) : Result<R>._(_value);

  /// Transforms a successful value, catching exceptions from [transform].
  ///
  /// Similar to [map], but wraps any exceptions thrown by [transform] in a Result.
  @pragma('vm:prefer-inline')
  Result<R> mapCatching<R>(Transformer<T, R> transform) => isSuccess
      ? runCatching(() => transform(_value as T))
      : Result<R>._(_value);

  /// Transforms a successful value to another [Result] using [transform].
  ///
  /// If successful, applies [transform] and returns its result.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      _value is _Failure
          ? Result<R>.failure(
              _value.exception,
              _value.stacktrace,
            )
          : transform(_value as T);
}

extension FutureResultTransformation<T> on Future<Result<T>> {
  /// Transforms a successful value using [transform].
  ///
  /// If successful, returns a new Result with the transformed value.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Future<Result<R>> map<R>(AsyncTransformer<T, R> transform) =>
      then((result) async => result._value is _Failure
          ? Result<R>._(result._value)
          : Result.success(await transform(result._value)));

  /// Transforms a successful value, catching exceptions from [transform].
  ///
  /// Similar to [map], but wraps any exceptions thrown by [transform] in a Result.
  @pragma('vm:prefer-inline')
  Future<Result<R>> mapCatching<R>(Transformer<T, R> transform) =>
      then((result) => result.mapCatching(transform));

  /// Transforms a successful value to another [Result] using [transform].
  ///
  /// If successful, applies [transform] and returns its result.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Future<Result<R>> flatMap<R>(Result<R> Function(T value) transform) =>
      then((result) => result.flatMap(transform));
}
