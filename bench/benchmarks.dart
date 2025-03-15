// ignore_for_file: avoid_print

import 'base/inline_benchs.dart';
import 'base/sealed_benchs.dart';
import 'base/sealed_in_place_benchs.dart';

/// Best way to run is compile this file with
/// `dart compile exe benchmarks.dart`
/// and then run AOT-version
/// `./benchmarks.exe`
///
/// Results from my M1 Pro:
///
/// const_inline_getOrNull(RunTime): 12.514792970414058 us.
/// const_sealed_getOrNull(RunTime): 81.85937245313774 us.
/// sealed_in_place_getOrNull(RunTime): 12.36518326963346 us.
///
/// const_inline_map(RunTime): 12.367751264497471 us.
/// const_sealed_map(RunTime): 131.57195105732146 us.
/// sealed_in_place_map(RunTime): 12.363551272897455 us.
///
/// const_inline_fold(RunTime): 12.360407279185441 us.
/// const_sealed_fold(RunTime): 91.93160073597056 us.
/// sealed_in_place_fold(RunTime): 12.360707278585442 us.
void main() {
  const InlineGetOrNullBench().report();
  const SealedGetOrNullBench().report();
  const SealedInPlaceGetOrNullBench().report();

  print('');

  const InlineMapBench().report();
  const SealedMapBench().report();
  const SealedInPlaceMapBench().report();

  print('');

  const InlineFoldBench().report();
  const SealedFoldBench().report();
  const SealedInPlaceFoldBench().report();
}
