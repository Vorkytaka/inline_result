part of 'result.dart';

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
