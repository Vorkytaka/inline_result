part of 'result.dart';

/// Internal class representing a failed Result.
@immutable
class _Failure {
  /// The exception encapsulated in this failure.
  final Exception exception;

  /// Optional stacktrace of this failure.
  final StackTrace? stacktrace;

  const _Failure(
    this.exception, [
    this.stacktrace,
  ]);

  @override
  String toString() {
    if (stacktrace != null) {
      return '_Failure($exception; $stacktrace)';
    }
    return '_Failure($exception)';
  }

  @override
  bool operator ==(Object other) =>
      other is _Failure &&
      exception == other.exception &&
      stacktrace == other.stacktrace;

  @override
  int get hashCode => Object.hash(exception, stacktrace);
}
