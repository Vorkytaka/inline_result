part of 'result.dart';

/// Internal class representing a failed Result.
@immutable
class _Failure {
  /// The exception encapsulated in this failure.
  final Exception exception;

  const _Failure(this.exception);

  @override
  String toString() => '_Failure($exception)';

  @override
  bool operator ==(Object other) =>
      other is _Failure && exception == other.exception;

  @override
  int get hashCode => exception.hashCode;
}
