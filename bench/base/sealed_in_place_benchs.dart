// ignore_for_file: unused_local_variable

import '../sealed/sealed_result.dart';
import 'bench_base.dart';

class SealedInPlaceGetOrNullBench extends BenchBase {
  const SealedInPlaceGetOrNullBench()
      : super(name: 'sealed_in_place_getOrNull');

  @override
  void run() {
    const result = SealedResult.success(value: 10);
    final value = switch (result) {
      SealedSuccess() => result.value,
      SealedFailure() => null,
    };
  }
}

class SealedInPlaceMapBench extends BenchBase {
  const SealedInPlaceMapBench() : super(name: 'sealed_in_place_map');

  @override
  void run() {
    const result = SealedResult.success(value: 10);
    final value = switch (result) {
      SealedSuccess() => SealedResult.success(value: result.value * 10),
      SealedFailure() => result,
    };
  }
}

class SealedInPlaceFoldBench extends BenchBase {
  const SealedInPlaceFoldBench() : super(name: 'sealed_in_place_fold');

  @override
  void run() {
    const result = SealedResult.success(value: 10);
    final value = switch (result) {
      SealedSuccess() => result.value * 10,
      SealedFailure() => -1,
    };
  }
}
