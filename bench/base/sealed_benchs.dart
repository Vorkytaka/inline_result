// ignore_for_file: unused_local_variable

import '../sealed/sealed_result.dart';
import 'bench_base.dart';

class SealedGetOrNullBench extends BenchBase {
  const SealedGetOrNullBench() : super(name: 'const_sealed_getOrNull');

  @override
  void run() {
    final value = const SealedResult.success(value: 10).getOrNull;
  }
}

class SealedMapBench extends BenchBase {
  const SealedMapBench() : super(name: 'const_sealed_map');

  @override
  void run() {
    final value = const SealedResult.success(value: 10).map((i) => i * 10);
  }
}

class SealedFoldBench extends BenchBase {
  const SealedFoldBench() : super(name: 'const_sealed_fold');

  @override
  void run() {
    final value = const SealedResult.success(value: 10).fold(
      onSuccess: (i) => i * 10,
      onFailure: (_, __) => -1,
    );
  }
}
