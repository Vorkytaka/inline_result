part of 'result.dart';

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
