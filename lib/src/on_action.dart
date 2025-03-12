part of 'result.dart';

extension ResultOnActions<T> on Result<T> {
  Result<T> onFailure(void Function(Exception exception) action) {
    final exc = exceptionOrNull;
    if (exc != null) {
      action(exc);
    }
    return this;
  }

  Result<T> onSuccess(void Function(T value) action) {
    if (isSuccess) {
      action(getOrThrow);
    }
    return this;
  }
}
