part of 'result.dart';

/// Extension providing transformation methods for [Result].
extension ResultTransformation<T, F extends Object> on Result<T, F> {
  /// Transforms a successful value using [transform].
  ///
  /// If successful, returns a new Result with the transformed value.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Result<R, F> map<R>(Transformer<T, R> transform) => isSuccess
      ? Result.success(transform(_value as T))
      : Result<R, F>._(_value);

  /// Transforms a successful value, catching exceptions from [transform].
  ///
  /// Similar to [map], but wraps any exceptions thrown by [transform] in a Result.
  @pragma('vm:prefer-inline')
  Result<R, F> mapCatching<R>(Transformer<T, R> transform) => isSuccess
      ? runCatching<R, F>(() => transform(_value as T))
      : Result<R, F>._(_value);

  /// Transforms a successful value to another [Result] using [transform].
  ///
  /// If successful, applies [transform] and returns its result.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Result<R, F> flatMap<R>(Result<R, F> Function(T value) transform) =>
      _value is _Failure<F>
          ? Result<R, F>.failure(
              _value.exception,
              _value.stacktrace,
            )
          : transform(_value as T);
}

extension FutureResultTransformation<T, F extends Object>
    on Future<Result<T, F>> {
  /// Transforms a successful value using [transform].
  ///
  /// If successful, returns a new Result with the transformed value.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Future<Result<R, F>> map<R>(AsyncTransformer<T, R> transform) =>
      then((result) async => result._value is _Failure<F>
          ? Result<R, F>._(result._value)
          : Result.success(await transform(result._value)));

  /// Transforms a successful value, catching exceptions from [transform].
  ///
  /// Similar to [map], but wraps any exceptions thrown by [transform] in a Result.
  @pragma('vm:prefer-inline')
  Future<Result<R, F>> mapCatching<R>(AsyncTransformer<T, R> transform) =>
      then((result) => result.isSuccess
          ? asyncRunCatching(() async => transform(result._value as T))
          : Future.value(Result<R, F>._(result._value)));

  /// Transforms a successful value to another [Result] using [transform].
  ///
  /// If successful, applies [transform] and returns its result.
  /// If failed, returns the original failure.
  @pragma('vm:prefer-inline')
  Future<Result<R, F>> flatMap<R>(
    FutureOr<Result<R, F>> Function(T value) transform,
  ) =>
      then((result) => result._value is _Failure<F>
          ? Result<R, F>.failure(
              result._value.exception,
              result._value.stacktrace,
            )
          : transform(result._value as T));
}
