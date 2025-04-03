part of 'result.dart';

/// Executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
@pragma('vm:prefer-inline')
Result<T, F> runCatching<T, F extends Object>(Block<T> block) {
  try {
    return Result.success(block());
  } on F catch (exception, stacktrace) {
    return Result.failure(exception, stacktrace);
  }
}

/// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
///
/// If [block] completes successfully, returns [Result.success] with the result.
/// If [block] throws, returns [Result.failure] with the exception.
Future<Result<T, F>> asyncRunCatching<T, F extends Object>(
  Future<T> Function() block,
) async {
  try {
    return Result.success(await block());
  } on F catch (exception, stacktrace) {
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
  Result<R, F> runCatching<R, F extends Object>(R Function(T value) block) {
    try {
      return Result.success(block(this));
    } on F catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }
}

/// Extension providing asyncRunCatching method for any Future.
extension FutureRunCatchingX<T> on Future<T> {
  /// Asynchronously executes [block] and wraps any thrown [Exception] in a [Result].
  ///
  /// If [block] completes successfully, returns [Result.success] with the result.
  /// If [block] throws, returns [Result.failure] with the exception.
  Future<Result<R, F>> asyncRunCatching<R, F extends Object>(
    FutureOr<R> Function(T value) block,
  ) async {
    try {
      return Result.success(await block(await this));
    } on F catch (exception, stacktrace) {
      return Result.failure(exception, stacktrace);
    }
  }
}
