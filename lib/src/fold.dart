part of 'result.dart';

/// Extension providing folding functionality for [Result].
extension ResultFold<T, F extends Object> on Result<T, F> {
  /// Combines both cases of Result into a single value.
  ///
  /// [onSuccess] handles successful values.
  /// [onFailure] handles exceptions.
  @pragma('vm:prefer-inline')
  R fold<R>({
    required Transformer<T, R> onSuccess,
    required FailureTransformer<R, F> onFailure,
  }) =>
      _value is _Failure<F>
          ? onFailure(_value.exception, _value.stacktrace)
          : onSuccess(_value as T);
}

/// Extension providing folding functionality for [Result].
extension FutureResultFold<T, F extends Object> on Future<Result<T, F>> {
  /// Combines both cases of Result into a single value.
  ///
  /// [onSuccess] handles successful values.
  /// [onFailure] handles exceptions.
  @pragma('vm:prefer-inline')
  Future<R> fold<R>({
    required AsyncTransformer<T, R> onSuccess,
    required AsyncFailureTransformer<R, F> onFailure,
  }) =>
      then((result) => result._value is _Failure<F>
          ? onFailure(result._value.exception, result._value.stacktrace)
          : onSuccess(result._value));
}
