import 'package:inline_result/inline_result.dart';

extension type RecordResult<T>._((T? value, Exception? exception) _value) {
  factory RecordResult.success(T value) => RecordResult._((value, null));

  factory RecordResult.failure(Exception exception) =>
      RecordResult._((null, exception));

  bool get isSuccess => _value.$1 != null;

  bool get isFailure => _value.$2 != null;
}

extension RecordResultUtils<T> on RecordResult<T> {
  @pragma('vm:prefer-inline')
  RecordResult<R> map<R>(Transformer<T, R> transformer) {
    return _value.$1 != null
        ? RecordResult.success(transformer(_value.$1!))
        : RecordResult<R>._((null, _value.$2));
  }

  @pragma('vm:prefer-inline')
  T? get getOrNull => _value.$1;

  @pragma('vm:prefer-inline')
  R fold<R>({
    required Transformer<T, R> onSuccess,
    required FailureTransformer<R, Exception> onFailure,
  }) {
    return _value.$1 != null
        ? onSuccess(_value.$1!)
        : onFailure(_value.$2!, null);
  }
}
