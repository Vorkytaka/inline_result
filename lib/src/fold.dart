part of 'result.dart';

extension ResultFold<T> on Result<T> {
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Exception exception) onFailure,
  }) {
    final exception = exceptionOrNull;
    if (exception != null) {
      return onFailure(exception);
    } else {
      return onSuccess(_value as T);
    }
  }
}
