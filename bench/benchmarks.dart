// ignore_for_file: avoid_print

import 'base/inline_benchs.dart';
import 'base/sealed_benchs.dart';

/// Best way to run is compile this file with
/// `dart compile exe benchmarks.dart`
/// and then run AOT-version
/// `./benchmarks.exe`
///
/// Results from my M1 Pro:
/// const_inline_getOrNull(RunTime): 12.365537268925463 us.
/// const_sealed_getOrNull(RunTime): 81.80953545232273 us.
///
/// const_inline_map(RunTime): 12.375395249209502 us.
/// const_sealed_map(RunTime): 132.0508115269957 us.
///
/// const_inline_fold(RunTime): 12.375485249029502 us.
/// const_sealed_fold(RunTime): 91.59131668039161 us.
void main() {
  const InlineGetOrNullBench().report();
  const SealedGetOrNullBench().report();

  print('');

  const InlineMapBench().report();
  const SealedMapBench().report();

  print('');

  const InlineFoldBench().report();
  const SealedFoldBench().report();
}
