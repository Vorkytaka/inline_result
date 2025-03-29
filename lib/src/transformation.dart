part of 'result.dart';

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
  Future<Result<R>> mapCatching<R>(AsyncTransformer<T, R> transform) =>
      then((result) => result.isSuccess
          ? asyncRunCatching(() async => transform(result._value as T))
          : Future.value(Result<R>._(result._value)));

  /// Transforms a successful value to another [Result] using [transform].
  ///
  /// If successful, applies [transform] and returns its result.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Future<Result<R>> flatMap<R>(
    FutureOr<Result<R>> Function(T value) transform,
  ) =>
      then((result) => result._value is _Failure
          ? Result<R>.failure(
              result._value.exception,
              result._value.stacktrace,
            )
          : transform(result._value as T));
}
