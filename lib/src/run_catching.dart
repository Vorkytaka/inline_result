part of 'result.dart';

/// Executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
@pragma('vm:prefer-inline')
Result<T> runCatching<T>(Block<T> block) {
  try {
    return Result.success(block());
  } on Exception catch (exception, stacktrace) {
    return Result.failure(exception, stacktrace);
  }
}

/// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
Future<Result<T>> asyncRunCatching<T>(Future<T> Function() block) async {
  try {
    return Result.success(await block());
  } on Exception catch (exception, stacktrace) {
    return Result.failure(exception, stacktrace);
  }
}

/// Extension providing runCatching method for any value.
extension RunCatchingX<T> on T {
  /// Executes [block] with current value as input
  /// and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  @pragma('vm:prefer-inline')
  Result<R> runCatching<R>(R Function(T value) block) {
    try {
      return Result.success(block(this));
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }

  /// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  Future<Result<R>> asyncRunCatching<R>(
    Future<R> Function(T value) block,
  ) async {
    try {
      return Result.success(await block(this));
    } on Exception catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }
}
