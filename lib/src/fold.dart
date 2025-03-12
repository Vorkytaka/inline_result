part of 'result.dart';

/// Extension providing folding functionality for [Result].
extension ResultFold<T> on Result<T> {
  /// Combines both cases of Result into a single value.
  ///
  /// [onSuccess] handles successful values.
  /// [onFailure] handles exceptions.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    final exception = exceptionOrNull;
    return exception != null ? onFailure(exception) : onSuccess(_value as T);
  }
}
