import 'dart:async';

import 'package:meta/meta.dart';

part 'failure.dart';

part 'fold.dart';

part 'future.dart';

part 'getter.dart';

part 'on_action.dart';

part 'or.dart';

part 'recover.dart';

part 'run_catching.dart';

part 'transformation.dart';

/// Transform success [value] into new value of [R].
typedef Transformer<T, R> = R Function(T value);

typedef AsyncTransformer<T, R> = FutureOr<R> Function(T value);

/// Transform failure result from [exception] and optional [stacktrace] into new value of [R].
typedef FailureTransformer<R, E extends Exception> = R Function(
  E exception,
  StackTrace? stacktrace,
);

typedef AsyncFailureTransformer<R, E extends Exception> = FutureOr<R> Function(
  E exception,
  StackTrace? stacktrace,
);

/// Execute block of code with given result of [T].
typedef Block<T> = T Function();

/// A discriminated union that encapsulates a successful outcome with a value of type [T]
/// or a failure with an [Exception].
///
/// This is implemented as an extension type for zero-cost wrapping, providing static type safety
/// while having no runtime overhead. Use [Result.success] to wrap successful values and
/// [Result.failure] to wrap exceptions.
extension type const Result<T>._(dynamic _value) {
  /// Creates a successful Result containing [value].
  const factory Result.success(T value) = Result._;

  /// Creates a failed Result containing [exception] and optional [stacktrace].
  factory Result.failure(Exception exception, [StackTrace? stacktrace]) =>
      Result._(_Failure(exception, stacktrace));

  /// Executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  @pragma('vm:prefer-inline')
  static Result<T> runCatching<T>(Block<T> block) {
    try {
      return Result.success(block());
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }

  /// Returns `true` if this [Result] is successful.
  bool get isSuccess => _value is! _Failure;

  /// Returns `true` if this [Result] is a failure.
  bool get isFailure => _value is _Failure;
}
