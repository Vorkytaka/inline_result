part of 'result.dart';

extension ResultRecover<T> on Result<T> {
  Result<R> recover<R>(R Function(Exception exception) transform) {
    final exc = exceptionOrNull;
    if (exc != null) {
      return Result.success(transform(exc));
    } else {
      return this as Result<R>;
    }
  }

  Result<R> recoverCatching<R>(R Function(Exception exception) transform) {
    final exc = exceptionOrNull;
    if (exc != null) {
      return Result.runCatching(() => transform(exc));
    } else {
      return this as Result<R>;
    }
  }
}
