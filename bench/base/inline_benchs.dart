// ignore_for_file: unused_local_variable

import 'package:inline_result/inline_result.dart';

import 'bench_base.dart';

class InlineGetOrNullBench extends BenchBase {
  const InlineGetOrNullBench() : super(name: 'const_inline_getOrNull');

  @override
  void run() {
    final value = const Result.success(10).getOrNull;
  }
}

class InlineMapBench extends BenchBase {
  const InlineMapBench() : super(name: 'const_inline_map');

  @override
  void run() {
    final value = const Result.success(10).map((i) => i * 10);
  }
}

class InlineFoldBench extends BenchBase {
  const InlineFoldBench() : super(name: 'const_inline_fold');

  @override
  void run() {
    final value = const Result.success(10).fold(
      onSuccess: (i) => i * 10,
      onFailure: (_, __) => -1,
    );
  }
}
