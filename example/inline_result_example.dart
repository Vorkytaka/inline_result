// ignore_for_file: avoid_print

import 'package:inline_result/inline_result.dart';

Result<int> divide(int a, int b) {
  return runCatching(() {
    if (b == 0) {
      throw Exception('Division by zero');
    }
    return a ~/ b;
  });
}

void main() {
  final success = divide(10, 2);
  final failure = divide(10, 0);

  print(success.getOrElse((e, st) => -1)); // Output: 5
  print(failure.getOrElse((e, st) => -1)); // Output: -1

  success.onSuccess((value) => print('Success: $value'));
  failure.onFailure((error, stacktrace) => print('Error: $error, $stacktrace'));

  final transformed = success.map((value) => 'Result: $value');
  print(transformed.getOrThrow); // Output: Result: 5

  final recovered = failure.recover((_, __) => 0);
  print(recovered.getOrThrow); // Output: 0
}
