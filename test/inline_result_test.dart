// result_test.dart
import 'package:inline_result/inline_result.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('runCatching success', () {
      final result = Result.runCatching(() => 'OK');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.getOrNull, equals('OK'));
      expect(result.exceptionOrNull, isNull);
      expect(result.getOrThrow, equals('OK'));
      expect(result.getOrElse((_) => 'fail'), equals('OK'));
      expect(result.getOrDefault('DEF'), equals('OK'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e) => 'EX:$e',
        ),
        equals('V:OK'),
      );
    });

    test('runCatching failure', () {
      final result = Result.runCatching(() => throw const CustomException('F'));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.getOrNull, isNull);
      expect(result.exceptionOrNull, isNotNull);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
      expect(
        result.getOrElse((e) => 'EX:$e'),
        startsWith('EX:CustomException: F'),
      );
      expect(result.getOrDefault('DEF'), equals('DEF'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e) => 'EX:$e',
        ),
        startsWith('EX:CustomException: F'),
      );
    });

    test('constructed success', () {
      final result = Result.success('OK');
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals('OK'));
    });

    test('constructed failure', () {
      final result = Result.failure<String>(const CustomException('F'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('map and mapCatching on success', () {
      final success = Result.success(10);
      final mapped = success.map((v) => v * 2);
      expect(mapped.getOrThrow, equals(20));

      final mappedCatching = success.mapCatching((v) => v * 2);
      expect(mappedCatching.getOrThrow, equals(20));

      // mapCatching should catch exceptions thrown during transformation.
      final resultCatching =
          success.mapCatching<int>((v) => throw const CustomException('FAIL'));
      expect(resultCatching.isFailure, isTrue);
      expect(() => resultCatching.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('map on failure should propagate failure', () {
      final failure = Result.failure<int>(const CustomException('F'));
      final mapped = failure.map<int>((v) => v * 2);
      expect(mapped.isFailure, isTrue);

      final mappedCatching = failure.mapCatching<int>((v) => v * 2);
      expect(mappedCatching.isFailure, isTrue);
    });
  });

  group('Result recover methods', () {
    test('recover on failure transforms exception to value', () {
      final failure = Result.failure<int>(const CustomException('F'));
      final recovered = failure.recover((e) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(42));
    });

    test('recover on success returns original value', () {
      final success = Result.success<int>(10);
      final recovered = success.recover((e) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(10));
    });

    test('recoverCatching on failure transforms exception to value', () {
      final failure = Result.failure<int>(const CustomException('F'));
      final recovered = failure.recoverCatching((e) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(42));
    });

    test('recoverCatching on failure catches transform exception', () {
      final failure = Result.failure<int>(const CustomException('F'));
      final recovered = failure
          .recoverCatching((e) => throw const CustomException('recoverFail'));
      expect(recovered.isFailure, isTrue);
      expect(() => recovered.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('recoverCatching on success returns original value', () {
      final success = Result.success<int>(10);
      final recovered = success.recoverCatching((e) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(10));
    });
  });

  group('Result action methods', () {
    test('onSuccess executes action and returns same result', () {
      int? captured;
      final success = Result.success<int>(10);
      final resultAfter = success.onSuccess((v) => captured = v);
      expect(captured, equals(10));
      expect(identical(success, resultAfter), isTrue);
    });

    test('onFailure executes action and returns same result', () {
      Object? captured;
      final failure = Result.failure<int>(const CustomException('F'));
      final resultAfter = failure.onFailure((e) => captured = e);
      expect(captured, isNotNull);
      expect(captured.toString(), contains('CustomException: F'));
      expect(identical(failure, resultAfter), isTrue);
    });
  });
}

class CustomException implements Exception {
  final String message;

  const CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
