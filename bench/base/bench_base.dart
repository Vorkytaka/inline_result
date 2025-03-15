import 'package:benchmark_harness/benchmark_harness.dart';

abstract class BenchBase extends BenchmarkBase {
  final int iterations;

  const BenchBase({
    required String name,
    this.iterations = 10000,
  })  : assert(iterations > 0),
        super(name);

  @override
  void exercise() {
    for (var i = 0; i < iterations; i++) {
      run();
    }
  }
}
