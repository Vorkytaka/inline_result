import 'dart:async';

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

    test('recover with specific exception type', () {
      bool isFormatCalled = false;
      bool isCustomCalled = false;
      final res = runCatching<int>(() {
        throw const FormatException();
      }).recover<FormatException>((_, __) {
        isFormatCalled = true;
        return 1;
      }).recover<CustomException>((_, __) {
        isCustomCalled = true;
        return 2;
      });

      expect(res, 1);
      expect(isFormatCalled, isTrue);
      expect(isCustomCalled, isFalse);
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

  group('FutureResultFold', () {
    test('fold on successful future', () async {
      final futureResult = Future.value(const Result.success(10));
      final folded = await futureResult.fold(
        onSuccess: (v) async => v * 2,
        onFailure: (e, st) async => 0,
      );
      expect(folded, equals(20));
    });

    test('fold on failing future', () async {
      final futureResult =
      Future.value(Result<int>.failure(const CustomException('fail')));
      final folded = await futureResult.fold(
        onSuccess: (v) async => v * 2,
        onFailure: (e, st) async => -1,
      );
      expect(folded, equals(-1));
    });
  });

  group('FutureResultGetter', () {
    test('getOrNull on successful future', () async {
      final result = await Future.value(const Result.success('OK')).getOrNull;
      expect(result, equals('OK'));
    });

    test('exceptionOrNull on failure future', () async {
      final result =
      await Future.value(Result<String>.failure(const CustomException('err')))
          .exceptionOrNull;
      expect(result.toString(), contains('CustomException: err'));
    });

    test('stacktraceOrNull on failure future returns non-null', () async {
      final result = await Future.value(
          Result<String>.failure(const CustomException('err'), StackTrace.current))
          .stacktraceOrNull;
      expect(result, isNotNull);
    });

    test('getOrThrow on successful future', () async {
      final result = await Future.value(const Result.success(42)).getOrThrow;
      expect(result, equals(42));
    });

    test('getOrThrow on failure future throws', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      expect(() async => future.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('FutureResultOnActions', () {
    test('onSuccess executes action on success', () async {
      int? captured;
      final result = await Future.value(const Result.success(5))
          .onSuccess((v) => captured = v);
      expect(captured, equals(5));
      expect(result.getOrThrow, equals(5));
    });

    test('onFailure executes action on failure', () async {
      Object? captured;
      final result = await Future.value(Result<int>.failure(const CustomException('fail')))
          .onFailure((e, st) => captured = e);
      expect(captured, isNotNull);
      expect(captured.toString(), contains('CustomException: fail'));
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('FutureResultOr', () {
    test('getOrElse returns value on success', () async {
      final future = Future.value(const Result.success(10));
      final value = await future.getOrElse((e, st) async => 0);
      expect(value, equals(10));
    });

    test('getOrElse returns fallback on failure', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      final value = await future.getOrElse((e, st) async => 99);
      expect(value, equals(99));
    });

    test('getOrDefault returns value on success', () async {
      final future = Future.value(const Result.success(10));
      final value = await future.getOrDefault(100);
      expect(value, equals(10));
    });

    test('getOrDefault returns default on failure', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      final value = await future.getOrDefault(100);
      expect(value, equals(100));
    });
  });

  group('FutureResultRecover', () {
    test('recover on future failure transforms to success', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      final recovered = await future.recover((e, st) async => 55);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(55));
    });

    test('recover on future success returns original value', () async {
      final future = Future.value(const Result.success(77));
      final recovered = await future.recover((e, st) async => 55);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(77));
    });

    test('recoverCatching on future failure transforms to success', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      final recovered = await future.recoverCatching((e, st) async => 88);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(88));
    });

    test('recoverCatching on future failure catches exception from transform', () async {
      final future = Future.value(Result<int>.failure(const CustomException('fail')));
      final recovered = await future.recoverCatching(
              (e, st) async => throw const CustomException('recovery fail'));
      expect(recovered.isFailure, isTrue);
      expect(() => recovered.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('recoverCatching on future success returns original value', () async {
      final future = Future.value(const Result.success(99));
      final recovered = await future.recoverCatching((e, st) async => 77);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(99));
    });
  });

  group('asyncRunCatching', () {
    test('asyncRunCatching returns success for successful block', () async {
      final result = await asyncRunCatching(() async => 'async OK');
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals('async OK'));
    });

    test('asyncRunCatching returns failure for throwing block', () async {
      final result = await asyncRunCatching(() async => throw const CustomException('async fail'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('FutureOrResult', () {
    test('asResult on synchronous value', () async {
      final result = await (42 as FutureOr<int>).asResult;
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(42));
    });

    test('asResult on failure using Future.sync', () async {
      final result = await Future.sync(() => throw const CustomException('sync error')).asResult;
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('RunCatchingX asyncRunCatching', () {
    test('asyncRunCatching on value succeeds', () async {
      final result = await 10.asyncRunCatching((v) async => v + 5);
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(15));
    });

    test('asyncRunCatching on value fails', () async {
      final result = await 10.asyncRunCatching<int>(
              (v) async => throw const CustomException('run async fail'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  group('FutureResultTransformation', () {
    test('map transforms future result on success', () async {
      final future = Future.value(const Result.success(5));
      final mapped = await future.map((v) async => v * 4);
      expect(mapped.isSuccess, isTrue);
      expect(mapped.getOrThrow, equals(20));
    });

    test('map propagates failure without transformation', () async {
      final future =
      Future.value(Result<int>.failure(const CustomException('fail')));
      final mapped = await future.map<int>((v) async => v * 4);
      expect(mapped.isFailure, isTrue);
    });

    test('mapCatching transforms future result on success', () async {
      final future = Future.value(const Result.success(3));
      final mapped = await future.mapCatching((v) => v + 7);
      expect(mapped.isSuccess, isTrue);
      expect(mapped.getOrThrow, equals(10));
    });

    test('mapCatching catches exception in transformation', () async {
      final future = Future.value(const Result.success(3));
      final mapped = await future.mapCatching<int>((v) => throw const CustomException('map async fail'));
      expect(mapped.isFailure, isTrue);
      expect(() => mapped.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('flatMap on future result applies transformation on success', () async {
      final future = Future.value(const Result.success(8));
      final flatMapped = await future.flatMap((v) => Result.success(v - 3));
      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.getOrThrow, equals(5));
    });

    test('flatMap on future result propagates failure from transform', () async {
      final future = Future.value(const Result.success(8));
      final flatMapped = await future.flatMap<int>(
              (v) => Result.failure(const CustomException('flatMap fail')));
      expect(flatMapped.isFailure, isTrue);
    });
  });
}

class CustomException implements Exception {
  final String message;

  const CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
