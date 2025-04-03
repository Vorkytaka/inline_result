part of 'result.dart';

/// Extension on [Future] to convert its result into a [Result].
///
/// This allows handling both success and failure cases of a [Future]
/// in a structured way using [Result].
///
/// Example usage:
/// ```dart
/// Future<int> asyncComputation() async => 42;
///
/// void main() async {
///   final result = await asyncComputation().asResult;
///
///   if (result.isSuccess) {
///     print('Success: ${result.getOrThrow}');
///   } else {
///     print('Failure: ${result.exceptionOrNull}');
///   }
/// }
/// ```
extension FutureResult<T> on Future<T> {
  /// Converts a [Future] into a [Result].
  ///
  /// - If the [Future] completes successfully, wraps the value in [Result.success].
  /// - If the [Future] completes with an [Exception], wraps the exception in [Result.failure].
  Future<Result<T, F>> asResult<F extends Object>() =>
      then(Result<T, F>.success).onError<F>(Result<T, F>.failure);
}

extension FutureOrResult<T> on FutureOr<T> {
  FutureOr<Result<T, F>> asResult<F extends Object>() async {
    try {
      return Result.success(await this);
    } on F catch (e, st) {
      return Result.failure(e, st);
    }
  }
}
