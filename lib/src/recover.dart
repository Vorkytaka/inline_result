part of 'result.dart';

/// Extension providing recovery methods for [Result].
extension ResultRecover<T extends R, R> on Result<T> {
  /// Transforms a failure into a success using [transform].
  ///
  /// If this [Result] is a failure, applies [transform] to the exception and returns
  /// a successful [Result] containing the transformed value.
  /// If successful, returns the original [Result].
  @pragma('vm:prefer-inline')
  Result<R> recover(FailureTransformer<R> transform) => _value is _Failure
      ? Result.success(transform(_value.exception, _value.stacktrace))
      : this;

  /// Transforms a failure into a success, catching exceptions from [transform].
  ///
  /// Similar to [recover], but wraps any exceptions thrown by [transform] in a [Result].
  @pragma('vm:prefer-inline')
  Result<R> recoverCatching(FailureTransformer<R> transform) => _value
          is _Failure
      ? Result.runCatching(() => transform(_value.exception, _value.stacktrace))
      : this;
}
