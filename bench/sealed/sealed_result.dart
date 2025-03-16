import 'package:inline_result/inline_result.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SealedResult<T> {
  const SealedResult();

  const factory SealedResult.success({required T value}) = SealedSuccess<T>;

  const factory SealedResult.failure({
    required Exception exception,
    required StackTrace? stacktrace,
  }) = SealedFailure<T>;

  bool get isSuccess;

  bool get isFailure;
}

@immutable
final class SealedSuccess<T> extends SealedResult<T> {
  final T value;

  const SealedSuccess({required this.value});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SealedSuccess &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  bool get isFailure => false;

  @override
  bool get isSuccess => true;
}

@immutable
final class SealedFailure<T> extends SealedResult<T> {
  final Exception exception;
  final StackTrace? stacktrace;

  const SealedFailure({
    required this.exception,
    required this.stacktrace,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SealedFailure &&
          runtimeType == other.runtimeType &&
          exception == other.exception &&
          stacktrace == other.stacktrace;

  @override
  int get hashCode => exception.hashCode ^ stacktrace.hashCode;

  @override
  bool get isFailure => true;

  @override
  bool get isSuccess => false;
}

extension SealedResultExt<T> on SealedResult<T> {
  SealedResult<R> map<R>(Transformer<T, R> transformer) {
    final current = this;
    return switch (current) {
      SealedSuccess() =>
        SealedResult.success(value: transformer(current.value)),
      SealedFailure() => SealedResult<R>.failure(
          exception: current.exception,
          stacktrace: current.stacktrace,
        ),
    };
  }

  T? get getOrNull {
    final current = this;
    return switch (current) {
      SealedSuccess() => current.value,
      SealedFailure() => null,
    };
  }

  R fold<R>({
    required Transformer<T, R> onSuccess,
    required FailureTransformer<R, Exception> onFailure,
  }) {
    final current = this;
    return switch (current) {
      SealedSuccess() => onSuccess(current.value),
      SealedFailure() => onFailure(current.exception, current.stacktrace),
    };
  }
}
