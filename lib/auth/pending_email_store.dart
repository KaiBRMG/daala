/// Remembers which address a sign-in link was sent to.
///
/// Firebase requires the email back when the link is opened, to stop a leaked
/// link from signing anyone in. On the same device we have it; if the link is
/// opened on a *different* device the store is empty and the screen asks for the
/// address instead of failing — that fallback is required, not optional, because
/// people routinely read mail on a laptop and tap the link there.
library;

import 'package:shared_preferences/shared_preferences.dart';

class PendingEmailStore {
  static const String _pendingEmailKey = 'daala.auth.pendingEmail';
  static const String _introSeenKey = 'daala.onboarding.introSeen';

  Future<void> savePendingEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email.trim());
  }

  Future<String?> readPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  Future<void> clearPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
  }

  /// Whether the value-proposition carousel has already been shown. A returning
  /// but signed-out user (they signed out, or a token expired) should land on
  /// the phone screen, not sit through the intro again.
  Future<bool> introSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_introSeenKey) ?? false;
  }

  Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introSeenKey, true);
  }
}
