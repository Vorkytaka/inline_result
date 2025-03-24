// ignore_for_file: avoid_print

import 'base/inline_benchs.dart';
import 'base/record_benchs.dart';
import 'base/sealed_benchs.dart';
import 'base/sealed_in_place_benchs.dart';

/// Best way to run is compile this file with
/// `dart compile exe benchmarks.dart`
/// and then run AOT-version
/// `./benchmarks.exe`
///
/// Results from my M1 Pro:
///
/// const_inline_getOrNull(RunTime): 9.761294275793604 us.
/// const_sealed_getOrNull(RunTime): 64.35255417956657 us.
/// sealed_in_place_getOrNull(RunTime): 9.754468547977218 us.
/// const_record_getOrNull(RunTime): 63.841952 us.
///
/// const_inline_map(RunTime): 9.746930322476452 us.
/// const_sealed_map(RunTime): 104.54297507706777 us.
/// sealed_in_place_map(RunTime): 9.747509820593082 us.
/// const_record_map(RunTime): 64.384128 us.
///
/// const_inline_fold(RunTime): 9.739629596203812 us.
/// const_sealed_fold(RunTime): 72.33922528619772 us.
/// sealed_in_place_fold(RunTime): 9.821186831142798 us.
/// const_record_fold(RunTime): 63.82588817982665 us.
void main() {
  const InlineGetOrNullBench().report();
  const SealedGetOrNullBench().report();
  const SealedInPlaceGetOrNullBench().report();
  const RecordGetOrNullBench().report();

  print('');

  const InlineMapBench().report();
  const SealedMapBench().report();
  const SealedInPlaceMapBench().report();
  const RecordMapBench().report();

  print('');

  const InlineFoldBench().report();
  const SealedFoldBench().report();
  const SealedInPlaceFoldBench().report();
  const RecordFoldBench().report();
}
