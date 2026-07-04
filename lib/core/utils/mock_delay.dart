import 'dart:math';

final Random _rng = Random();

/// Artificial 300–800 ms delay for every Mock* repository call so loading
/// (shimmer) states are exercised in Phase 1.
Future<void> mockNetworkDelay() =>
    Future<void>.delayed(Duration(milliseconds: 300 + _rng.nextInt(501)));
