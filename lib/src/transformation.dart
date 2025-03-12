part of 'result.dart';

/// Extension providing transformation methods for [Result].
extension ResultTransformation<T> on Result<T> {
  /// Transforms a successful value using [transform].
  ///
  /// If successful, returns a new Result with the transformed value.
  /// If failed, returns the original failure.
  Result<R> map<R>(R Function(T value) transform) =>
      isSuccess ? Result.success<R>(transform(_value as T)) : Result._(_value);

  /// Transforms a successful value, catching exceptions from [transform].
  ///
  /// Similar to [map], but wraps any exceptions thrown by [transform] in a Result.
  Result<R> mapCatching<R>(R Function(T value) transform) => isSuccess
      ? Result.runCatching(() => transform(_value as T))
      : Result._(_value);
}
