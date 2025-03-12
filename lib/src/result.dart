import 'package:meta/meta.dart';

part 'failure.dart';

part 'fold.dart';

part 'on_action.dart';

part 'recover.dart';

part 'transformation.dart';

extension type Result<T>._(dynamic _value) {
  static Result<T> success<T>(T value) => Result._(value);

  static Result<T> failure<T>(Exception exception) =>
      Result._(_Failure(exception));

  static Result<T> runCatching<T>(T Function() block) {
    try {
      return Result.success(block());
    } on Exception catch (exception) {
      return Result.failure(exception);
    }
  }

  bool get isSuccess => _value is! _Failure;

  bool get isFailure => _value is _Failure;

  T? get getOrNull {
    if (isFailure) {
      return null;
    } else {
      return _value as T;
    }
  }

  Exception? get exceptionOrNull {
    if (isFailure) {
      return (_value as _Failure).exception;
    } else {
      return null;
    }
  }

  T get getOrThrow {
    if (isFailure) {
      throw (_value as _Failure).exception;
    } else {
      return _value as T;
    }
  }
}

extension ResultOr<T extends R, R> on Result<T> {
  R getOrElse(R Function(Exception exception) onFailure) {
    final exception = exceptionOrNull;
    if (exception != null) {
      return onFailure(exception);
    } else {
      return _value as T;
    }
  }

  R getOrDefault(R defaultValue) {
    if (isFailure) {
      return defaultValue;
    } else {
      return _value as T;
    }
  }
}
