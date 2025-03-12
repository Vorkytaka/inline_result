part of 'result.dart';

extension ResultTransformation<T> on Result<T> {
  Result<R> map<R>(R Function(T value) transform) {
    if (isSuccess) {
      return Result.success<R>(transform(_value as T));
    } else {
      return Result._(_value);
    }
  }

  Result<R> mapCatching<R>(R Function(T value) transform) {
    if (isSuccess) {
      return Result.runCatching(() => transform(_value as T));
    } else {
      return Result._(_value);
    }
  }
}
