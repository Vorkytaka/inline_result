import 'package:meta/meta.dart';

part 'failure.dart';

part 'fold.dart';

part 'on_action.dart';

part 'or.dart';

part 'recover.dart';

part 'transformation.dart';

/// A discriminated union that encapsulates a successful outcome with a value of type [T]
/// or a failure with an [Exception].
///
/// This is implemented as an extension type for zero-cost wrapping, providing static type safety
/// while having no runtime overhead. Use [Result.success] to wrap successful values and
/// [Result.failure] to wrap exceptions.
///
/// To safely execute code that might throw, use [Result.runCatching].
extension type Result<T>._(dynamic _value) {
  /// Creates a successful Result containing [value].
  static Result<T> success<T>(T value) => Result._(value);

  /// Creates a failed Result containing [exception].
  static Result<T> failure<T>(Exception exception) =>
      Result._(_Failure(exception));

  /// Executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  static Result<T> runCatching<T>(T Function() block) {
    try {
      return Result.success(block());
    } on Exception catch (exception) {
      return Result.failure(exception);
    }
  }

  /// Returns `true` if this [Result] is successful.
  bool get isSuccess => _value is! _Failure;

  /// Returns `true` if this [Result] is a failure.
  bool get isFailure => _value is _Failure;

  /// Returns the encapsulated value if successful, otherwise `null`.
  T? get getOrNull => isFailure ? null : _value as T;

  /// Returns the encapsulated exception if failed, otherwise `null`.
  Exception? get exceptionOrNull =>
      isFailure ? (_value as _Failure).exception : null;

  /// Returns the encapsulated value if successful, otherwise throws the exception.
  ///
  /// Throws the encapsulated [Exception] if this Result is a failure.
  T get getOrThrow {
    if (isFailure) {
      throw (_value as _Failure).exception;
    } else {
      return _value as T;
    }
  }
}
