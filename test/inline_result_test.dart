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
      expect(result.getOrElse((_, __) => 'fail'), equals('OK'));
      expect(result.getOrDefault('DEF'), equals('OK'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e, st) => 'EX:$e',
        ),
        equals('V:OK'),
      );
    });

    test('runCatching failure', () {
      final result =
          runCatching<String>(() => throw const CustomException('F'));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.getOrNull, isNull);
      expect(result.exceptionOrNull, isNotNull);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
      expect(
        result.getOrElse((e, __) => 'EX:$e'),
        startsWith('EX:CustomException: F'),
      );
      expect(result.getOrDefault('DEF'), equals('DEF'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e, st) => 'EX:$e',
        ),
        startsWith('EX:CustomException: F'),
      );
    });

    test('constructed success', () {
      const result = Result.success('OK');
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals('OK'));
    });

    test('constructed failure', () {
      final result = Result<String>.failure(const CustomException('F'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('map and mapCatching on success', () {
      const success = Result.success(10);
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
      final failure =
          Result<int>.failure(const CustomException('F'), StackTrace.empty);
      final mapped = failure.map<int>((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.stacktraceOrNull, isNotNull);

      final mappedCatching = failure.mapCatching<int>((v) => v * 2);
      expect(mappedCatching.isFailure, isTrue);
      expect(mappedCatching.stacktraceOrNull, isNotNull);
    });
  });

  group('Result recover methods', () {
    test('recover on failure transforms exception to value', () {
      final failure = Result<int>.failure(const CustomException('F'));
      final recovered = failure.recover((e, _) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(42));
    });

    test('recover on success returns original value', () {
      const success = Result<int>.success(10);
      final recovered = success.recover((e, _) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(10));
    });

    test('recoverCatching on failure transforms exception to value', () {
      final failure = Result<int>.failure(const CustomException('F'));
      final recovered = failure.recoverCatching((e, _) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(42));
    });

    test('recoverCatching on failure catches transform exception', () {
      final failure = Result<int>.failure(const CustomException('F'));
      final recovered = failure.recoverCatching(
          (e, _) => throw const CustomException('recoverFail'));
      expect(recovered.isFailure, isTrue);
      expect(() => recovered.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('recoverCatching on success returns original value', () {
      const success = Result.success(10);
      final recovered = success.recoverCatching((e, _) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(10));
    });
  });

  group('Result action methods', () {
    test('onSuccess executes action and returns same result', () {
      int? captured;
      const success = Result.success(10);
      final resultAfter = success.onSuccess((v) => captured = v);
      expect(captured, equals(10));
      expect(identical(success, resultAfter), isTrue);
    });

    test('onFailure executes action and returns same result', () {
      Object? captured;
      final failure = Result<int>.failure(const CustomException('F'));
      final resultAfter = failure.onFailure((e, _) => captured = e);
      expect(captured, isNotNull);
      expect(captured.toString(), contains('CustomException: F'));
      expect(identical(failure, resultAfter), isTrue);
    });
  });

  group('Additional tests', () {
    test('stacktraceOrNull on success returns null', () {
      const success = Result.success('OK');
      expect(success.stacktraceOrNull, isNull);
    });

    test('stacktraceOrNull on failure returns non-null', () {
      // Use a non-const exception to increase the likelihood of a non-null stacktrace.
      final result = Result.runCatching(() {
        throw CustomException(DateTime.now().toIso8601String());
      });
      expect(result.isFailure, isTrue);
      expect(result.stacktraceOrNull, isNotNull);
    });

    test('runCatching success', () {
      final result = runCatching(() => 'OK');
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.getOrNull, equals('OK'));
      expect(result.exceptionOrNull, isNull);
      expect(result.getOrThrow, equals('OK'));
      expect(result.getOrElse((_, __) => 'fail'), equals('OK'));
      expect(result.getOrDefault('DEF'), equals('OK'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e, st) => 'EX:$e',
        ),
        equals('V:OK'),
      );
    });

    test('runCatching failure', () {
      final result =
          runCatching<String>(() => throw const CustomException('F'));
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.getOrNull, isNull);
      expect(result.exceptionOrNull, isNotNull);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
      expect(
        result.getOrElse((e, __) => 'EX:$e'),
        startsWith('EX:CustomException: F'),
      );
      expect(result.getOrDefault('DEF'), equals('DEF'));
      expect(
        result.fold(
          onSuccess: (value) => 'V:$value',
          onFailure: (e, st) => 'EX:$e',
        ),
        startsWith('EX:CustomException: F'),
      );
    });

    test('RunCatchingX extension method success', () {
      final result = 5.runCatching((v) => v * 3);
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(15));
    });

    test('RunCatchingX extension method failure', () {
      final result = 5.runCatching((v) {
        throw const CustomException('error from RunCatchingX');
      });
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('FutureResult Extension', () {
    test('asResult on successful future', () async {
      final future = Future.value(42);
      final result = await future.asResult;

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(42));
    });

    test('asResult on failing future with Exception', () async {
      final future = Future<int>.error(Exception('Failure occurred'));
      final result = await future.asResult;

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<Exception>());
      expect(result.exceptionOrNull.toString(), contains('Failure occurred'));
    });

    test('asResult on failing future with CustomException', () async {
      final future = Future<int>.error(const CustomException('Custom failure'));
      final result = await future.asResult;

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<CustomException>());
      expect(result.exceptionOrNull.toString(), contains('Custom failure'));
    });

    test('asResult on failing future with non-Exception error (ignored)',
        () async {
      final future = Future<int>.error('Non-exception error');
      expect(future.asResult, throwsA(isA<String>()));
    });

    test('asResult on delayed success', () async {
      final future = Future.delayed(const Duration(milliseconds: 50), () => 99);
      final result = await future.asResult;

      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(99));
    });

    test('asResult on delayed failure', () async {
      final future = Future<int>.delayed(
        const Duration(milliseconds: 50),
        () => throw Exception('Delayed failure'),
      );

      final result = await future.asResult;

      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<Exception>());
      expect(result.exceptionOrNull.toString(), contains('Delayed failure'));
    });
  });

  group('flatMap', () {
    test('flatMap on success applies transform and returns new result', () {
      // Given a successful result with value 10.
      const success = Result.success(10);
      // When flatMap applies a transform returning a new success.
      final result = success.flatMap((v) => Result.success(v * 2));
      // Then the new result should be successful with value 20.
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(20));
    });

    test('flatMap on success propagates failure returned by transform', () {
      // Given a successful result with value 10.
      const success = Result.success(10);
      // When flatMap applies a transform that returns a failure.
      final result = success.flatMap<int>(
        (v) => Result.failure(const CustomException('flat failure')),
      );
      // Then the new result should be a failure.
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });

    test(
        'flatMap on failure propagates original failure without calling transform',
        () {
      // Given a failed result.
      final failure =
          Result<int>.failure(const CustomException('original failure'));
      var transformCalled = false;
      // When flatMap is invoked; the transform should not be executed.
      final result = failure.flatMap((v) {
        transformCalled = true;
        return Result.success(v * 2);
      });
      // Then the result remains the original failure.
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
      expect(transformCalled, isFalse);
    });
  });
}

class CustomException implements Exception {
  final String message;

  const CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
