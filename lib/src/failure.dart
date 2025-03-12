part of 'result.dart';

@immutable
class _Failure {
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
