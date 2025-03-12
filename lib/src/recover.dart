part of 'result.dart';

/// Extension providing recovery methods for [Result].
extension ResultRecover<T> on Result<T> {
  /// Transforms a failure into a success using [transform].
  ///
  /// If this [Result] is a failure, applies [transform] to the exception and returns
  /// a successful [Result] containing the transformed value.
  /// If successful, returns the original [Result].
  Result<R> recover<R>(R Function(Exception exception) transform) {
    final exc = exceptionOrNull;
    return exc != null ? Result.success(transform(exc)) : this as Result<R>;
  }

  /// Transforms a failure into a success, catching exceptions from [transform].
  ///
  /// Similar to [recover], but wraps any exceptions thrown by [transform] in a [Result].
  Result<R> recoverCatching<R>(R Function(Exception exception) transform) {
    final exc = exceptionOrNull;
    return exc != null
        ? Result.runCatching(() => transform(exc))
        : this as Result<R>;
  }
}
