import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_mode.dart';

/// Phase 1 mock auth/session state. No Firebase — sign-in simply flips a
/// flag. The router listens to this to guard the app shell.
class MockSession extends ChangeNotifier {
  bool _signedIn = false;
  UserMode _mode = UserMode.consumer;
  bool _isVerified = false;

  static const String userId = 'u-me';
  static const String displayName = 'Thandi Mokoena';
  static const String firstName = 'Thandi';

  bool get signedIn => _signedIn;

  /// Current Consumer ⇄ Merchant mode (lightweight context switch).
  UserMode get mode => _mode;
  bool get isVerified => _isVerified;

  void signIn() {
    _signedIn = true;
    notifyListeners();
  }

  void signOut() {
    _signedIn = false;
    _isVerified = false;
    notifyListeners();
  }

  void setMode(UserMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Mock KYC success — unlocks the verification badge.
  void markVerified() {
    _isVerified = true;
    notifyListeners();
  }
}

final sessionProvider = Provider<MockSession>((ref) => MockSession());
