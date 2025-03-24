// ignore_for_file: unused_local_variable

import '../record_result.dart';
import 'bench_base.dart';

class RecordGetOrNullBench extends BenchBase {
  const RecordGetOrNullBench() : super(name: 'const_record_getOrNull');

  @override
  void run() {
    final value = RecordResult.success(10).getOrNull;
  }
}

class RecordMapBench extends BenchBase {
  const RecordMapBench() : super(name: 'const_record_map');

  @override
  void run() {
    final value = RecordResult.success(10).map((i) => i * 10);
  }
}

class RecordFoldBench extends BenchBase {
  const RecordFoldBench() : super(name: 'const_record_fold');

  @override
  void run() {
    final value = RecordResult.success(10).fold(
      onSuccess: (i) => i * 10,
      onFailure: (_, __) => -1,
    );
  }
}
