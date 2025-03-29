import 'dart:async';

import 'package:inline_result/inline_result.dart';
import 'package:test/test.dart';

void main() {
  //
  // Synchronous Result Tests
  //
  group('Synchronous Result Tests', () {
    test('runCatching returns success when block succeeds', () {
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

    test('runCatching returns failure when block throws', () {
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

    test('constructed success result returns correct value', () {
      const result = Result.success('OK');
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals('OK'));
    });

    test('constructed failure result throws on getOrThrow', () {
      final result = Result<String>.failure(const CustomException('F'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('map and mapCatching transform success correctly', () {
      // Testing map on a success.
      const success = Result.success(10);
      final mapped = success.map((v) => v * 2);
      expect(mapped.getOrThrow, equals(20));

      // Testing mapCatching on a success.
      final mappedCatching = success.mapCatching((v) => v * 2);
      expect(mappedCatching.getOrThrow, equals(20));

      // mapCatching should catch exceptions thrown during transformation.
      final resultCatching =
          success.mapCatching<int>((v) => throw const CustomException('FAIL'));
      expect(resultCatching.isFailure, isTrue);
      expect(() => resultCatching.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('map on failure propagates the original failure', () {
      final failure =
          Result<int>.failure(const CustomException('F'), StackTrace.empty);
      final mapped = failure.map<int>((v) => v * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.stacktraceOrNull, isNotNull);

      final mappedCatching = failure.mapCatching<int>((v) => v * 2);
      expect(mappedCatching.isFailure, isTrue);
      expect(mappedCatching.stacktraceOrNull, isNotNull);
    });

    test('flatMap transforms success and propagates failure', () {
      // flatMap on success returns new success.
      const success = Result.success(10);
      final flatMapped = success.flatMap((v) => Result.success(v * 2));
      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.getOrThrow, equals(20));

      // flatMap on success returning a failure.
      final flatFailure = success.flatMap<int>(
        (v) => Result.failure(const CustomException('flat failure')),
      );
      expect(flatFailure.isFailure, isTrue);
      expect(() => flatFailure.getOrThrow, throwsA(isA<CustomException>()));

      // flatMap on failure should not execute the transformation.
      final originalFailure =
          Result<int>.failure(const CustomException('original failure'));
      var transformCalled = false;
      final propagated = originalFailure.flatMap((v) {
        transformCalled = true;
        return Result.success(v * 2);
      });
      expect(propagated.isFailure, isTrue);
      expect(() => propagated.getOrThrow, throwsA(isA<CustomException>()));
      expect(transformCalled, isFalse);
    });

    test('recover and recoverCatching work as expected', () {
      // recover transforms failure to success.
      final failure = Result<int>.failure(const CustomException('F'));
      final recovered = failure.recover((e, _) => 42);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(42));

      // recover with specific exception type.
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

      // recover on a success should return the original value.
      const success = Result<int>.success(10);
      final recovSuccess = success.recover((e, _) => 42);
      expect(recovSuccess.isSuccess, isTrue);
      expect(recovSuccess.getOrThrow, equals(10));

      // recoverCatching transforms failure to success.
      final failure2 = Result<int>.failure(const CustomException('F'));
      final recoveredCatching = failure2.recoverCatching((e, _) => 42);
      expect(recoveredCatching.isSuccess, isTrue);
      expect(recoveredCatching.getOrThrow, equals(42));

      // recoverCatching catches exception thrown in the recovery transform.
      final failure3 = Result<int>.failure(const CustomException('F'));
      final recoveredCatchingFail = failure3.recoverCatching(
          (e, _) => throw const CustomException('recoverFail'));
      expect(recoveredCatchingFail.isFailure, isTrue);
      expect(() => recoveredCatchingFail.getOrThrow,
          throwsA(isA<CustomException>()));

      // recoverCatching on a success returns the original value.
      final success2 = Result.success(10);
      final recoveredCatchingSuccess = success2.recoverCatching((e, _) => 42);
      expect(recoveredCatchingSuccess.isSuccess, isTrue);
      expect(recoveredCatchingSuccess.getOrThrow, equals(10));
    });

    test('onSuccess and onFailure actions execute correctly', () {
      int? successCapture;
      const successResult = Result.success(10);
      final afterSuccess = successResult.onSuccess((v) => successCapture = v);
      expect(successCapture, equals(10));
      expect(identical(successResult, afterSuccess), isTrue);

      Object? failureCapture;
      final failureResult = Result<int>.failure(const CustomException('F'));
      final afterFailure =
          failureResult.onFailure((e, _) => failureCapture = e);
      expect(failureCapture, isNotNull);
      expect(failureCapture.toString(), contains('CustomException: F'));
      expect(identical(failureResult, afterFailure), isTrue);
    });

    test('stacktraceOrNull returns appropriate values', () {
      const successResult = Result.success('OK');
      expect(successResult.stacktraceOrNull, isNull);

      // For a failure, the stacktrace should be non-null.
      final failureResult = Result.runCatching(() {
        throw CustomException(DateTime.now().toIso8601String());
      });
      expect(failureResult.isFailure, isTrue);
      expect(failureResult.stacktraceOrNull, isNotNull);
    });
  });

  //
  // Extension Method Tests (RunCatchingX)
  //
  group('Extension Method Tests', () {
    test('RunCatchingX extension returns success when transformation succeeds',
        () {
      final result = 5.runCatching((v) => v * 3);
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(15));
    });

    test('RunCatchingX extension returns failure when transformation throws',
        () {
      final result = 5.runCatching((v) {
        throw const CustomException('error from RunCatchingX');
      });
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('asyncRunCatching extension returns success for async block',
        () async {
      final result = await Future.value(10).asyncRunCatching((v) => v + 5);
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(15));
    });

    test(
        'asyncRunCatching extension returns failure for async block throwing error',
        () async {
      final result = await Future.value(10).asyncRunCatching<int>(
          (v) => throw const CustomException('run async fail'));
      expect(result.isFailure, isTrue);
      expect(() => result.getOrThrow, throwsA(isA<CustomException>()));
    });
  });

  //
  // Future Result Tests
  //
  group('Future Result Tests', () {
    test('asResult converts successful future to success', () async {
      final future = Future.value(42);
      final result = await future.asResult;
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(42));
    });

    test('asResult converts failing future (Exception) to failure', () async {
      final future = Future<int>.error(Exception('Failure occurred'));
      final result = await future.asResult;
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<Exception>());
      expect(result.exceptionOrNull.toString(), contains('Failure occurred'));
    });

    test('asResult converts failing future (CustomException) to failure',
        () async {
      final future = Future<int>.error(const CustomException('Custom failure'));
      final result = await future.asResult;
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<CustomException>());
      expect(result.exceptionOrNull.toString(), contains('Custom failure'));
    });

    test('asResult on failing future with non-Exception error throws',
        () async {
      final future = Future<int>.error('Non-exception error');
      expect(future.asResult, throwsA(isA<String>()));
    });

    test('asResult converts delayed success to success', () async {
      final future = Future.delayed(const Duration(milliseconds: 50), () => 99);
      final result = await future.asResult;
      expect(result.isSuccess, isTrue);
      expect(result.getOrThrow, equals(99));
    });

    test('asResult converts delayed failure to failure', () async {
      final future = Future<int>.delayed(
        const Duration(milliseconds: 50),
        () => throw Exception('Delayed failure'),
      );
      final result = await future.asResult;
      expect(result.isFailure, isTrue);
      expect(result.exceptionOrNull, isA<Exception>());
      expect(result.exceptionOrNull.toString(), contains('Delayed failure'));
    });

    test('Future fold on success computes correct value', () async {
      final futureResult = Future.value(const Result.success(10));
      final folded = await futureResult.fold(
        onSuccess: (v) async => v * 2,
        onFailure: (e, st) async => 0,
      );
      expect(folded, equals(20));
    });

    test('Future fold on failure computes fallback value', () async {
      final futureResult =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final folded = await futureResult.fold(
        onSuccess: (v) async => v * 2,
        onFailure: (e, st) async => -1,
      );
      expect(folded, equals(-1));
    });

    test('Future getters return correct values on success and failure',
        () async {
      final successResult =
          await Future.value(const Result.success('OK')).getOrNull;
      expect(successResult, equals('OK'));

      final failureResult = await Future.value(
              Result<String>.failure(const CustomException('err')))
          .exceptionOrNull;
      expect(failureResult.toString(), contains('CustomException: err'));

      final stacktrace = await Future.value(Result<String>.failure(
              const CustomException('err'), StackTrace.current))
          .stacktraceOrNull;
      expect(stacktrace, isNotNull);

      final value = await Future.value(const Result.success(42)).getOrThrow;
      expect(value, equals(42));

      final futureFail =
          Future.value(Result<int>.failure(const CustomException('fail')));
      expect(
          () async => futureFail.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('Future onSuccess and onFailure execute correct actions', () async {
      int? capturedSuccess;
      final successFuture = await Future.value(const Result.success(5))
          .onSuccess((v) => capturedSuccess = v);
      expect(capturedSuccess, equals(5));
      expect(successFuture.getOrThrow, equals(5));

      Object? capturedFailure;
      final failureFuture =
          await Future.value(Result<int>.failure(const CustomException('fail')))
              .onFailure((e, st) => capturedFailure = e);
      expect(capturedFailure, isNotNull);
      expect(capturedFailure.toString(), contains('CustomException: fail'));
      expect(() => failureFuture.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('Future getOrElse and getOrDefault return correct values', () async {
      final futureSuccess = Future.value(const Result.success(10));
      final valueSuccess = await futureSuccess.getOrElse((e, st) async => 0);
      expect(valueSuccess, equals(10));

      final futureFailure =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final valueFailure = await futureFailure.getOrElse((e, st) async => 99);
      expect(valueFailure, equals(99));

      final defaultSuccess =
          await Future.value(const Result.success(10)).getOrDefault(100);
      expect(defaultSuccess, equals(10));

      final defaultFailure =
          await Future.value(Result<int>.failure(const CustomException('fail')))
              .getOrDefault(100);
      expect(defaultFailure, equals(100));
    });

    test('Future recover and recoverCatching work as expected', () async {
      // recover transforms failure into a success value.
      final futureFailure =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final recovered = await futureFailure.recover((e, st) async => 55);
      expect(recovered.isSuccess, isTrue);
      expect(recovered.getOrThrow, equals(55));

      // On a success, recover returns the original value.
      final futureSuccess = Future.value(const Result.success(77));
      final recoveredSuccess = await futureSuccess.recover((e, st) async => 55);
      expect(recoveredSuccess.isSuccess, isTrue);
      expect(recoveredSuccess.getOrThrow, equals(77));

      // recoverCatching transforms failure to success.
      final futureFailure2 =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final recoveredCatching =
          await futureFailure2.recoverCatching((e, st) async => 88);
      expect(recoveredCatching.isSuccess, isTrue);
      expect(recoveredCatching.getOrThrow, equals(88));

      // recoverCatching catches exception in the recovery transform.
      final futureFailure3 =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final recoveredCatchingFail = await futureFailure3.recoverCatching(
          (e, st) async => throw const CustomException('recovery fail'));
      expect(recoveredCatchingFail.isFailure, isTrue);
      expect(() => recoveredCatchingFail.getOrThrow,
          throwsA(isA<CustomException>()));

      // recoverCatching on a success returns the original value.
      final futureSuccess2 = Future.value(const Result.success(99));
      final recoveredCatchingSuccess =
          await futureSuccess2.recoverCatching((e, st) async => 77);
      expect(recoveredCatchingSuccess.isSuccess, isTrue);
      expect(recoveredCatchingSuccess.getOrThrow, equals(99));
    });

    test('asyncRunCatching returns correct result for async blocks', () async {
      final successResult = await asyncRunCatching(() async => 'async OK');
      expect(successResult.isSuccess, isTrue);
      expect(successResult.getOrThrow, equals('async OK'));

      final failureResult = await asyncRunCatching(
          () async => throw const CustomException('async fail'));
      expect(failureResult.isFailure, isTrue);
      expect(() => failureResult.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('asResult on FutureOr values works correctly', () async {
      final syncResult = await (42 as FutureOr<int>).asResult;
      expect(syncResult.isSuccess, isTrue);
      expect(syncResult.getOrThrow, equals(42));

      final syncFailure =
          await Future.sync(() => throw const CustomException('sync error'))
              .asResult;
      expect(syncFailure.isFailure, isTrue);
      expect(() => syncFailure.getOrThrow, throwsA(isA<CustomException>()));
    });

    test('Future Result Transformation methods (map, mapCatching, flatMap)',
        () async {
      // map transforms a successful future result.
      final futureSuccessMap = Future.value(const Result.success(5));
      final mapped = await futureSuccessMap.map((v) async => v * 4);
      expect(mapped.isSuccess, isTrue);
      expect(mapped.getOrThrow, equals(20));

      // map propagates failure without transformation.
      final futureFailureMap =
          Future.value(Result<int>.failure(const CustomException('fail')));
      final mappedFailure = await futureFailureMap.map<int>((v) async => v * 4);
      expect(mappedFailure.isFailure, isTrue);

      // mapCatching transforms a successful future result.
      final futureSuccessMapCatching = Future.value(const Result.success(3));
      final mappedCatching =
          await futureSuccessMapCatching.mapCatching((v) => v + 7);
      expect(mappedCatching.isSuccess, isTrue);
      expect(mappedCatching.getOrThrow, equals(10));

      // mapCatching catches exception in the transformation.
      final futureSuccessMapCatchingFail =
          Future.value(const Result.success(3));
      final mappedCatchingFail =
          await futureSuccessMapCatchingFail.mapCatching<int>(
              (v) => throw const CustomException('map async fail'));
      expect(mappedCatchingFail.isFailure, isTrue);
      expect(
          () => mappedCatchingFail.getOrThrow, throwsA(isA<CustomException>()));

      // flatMap on a future result applies transformation on success.
      final futureSuccessFlatMap = Future.value(const Result.success(8));
      final flatMapped =
          await futureSuccessFlatMap.flatMap((v) => Result.success(v - 3));
      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.getOrThrow, equals(5));

      // flatMap on a future result propagates failure from transformation.
      final futureSuccessFlatMapFail = Future.value(const Result.success(8));
      final flatMappedFail = await futureSuccessFlatMapFail.flatMap<int>(
          (v) => Result.failure(const CustomException('flatMap fail')));
      expect(flatMappedFail.isFailure, isTrue);
    });
  });
}

class CustomException implements Exception {
  final String message;

  const CustomException(this.message);

  @override
  String toString() => 'CustomException: $message';
}
