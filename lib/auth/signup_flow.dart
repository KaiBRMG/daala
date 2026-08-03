/// In-flight state for one pass through the sign-in / onboarding flow.
///
/// Kept in a provider rather than passed as route `extra` so that going back to
/// change a number, or being bounced out to the OS for an SMS, does not lose the
/// consent timestamp or force a fresh verification.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'phone_format.dart';

class SignupDraft {
  const SignupDraft({
    this.region = kDefaultRegion,
    this.nationalDigits = '',
    this.consentAcceptedAt,
    this.termsVersion,
    this.privacyVersion,
    this.verification,
  });

  final DialRegion region;
  final String nationalDigits;

  /// When the user tapped "Send Code" under the consent line.
  ///
  /// There is no uid at that moment, so nothing can be written to Firestore
  /// yet — phase2.md's "log consent timestamp on Send Code" is not implementable
  /// as written. The timestamp travels here and lands on the first authenticated
  /// write, in the same batch as the profile.
  final DateTime? consentAcceptedAt;

  final int? termsVersion;
  final int? privacyVersion;

  /// Set once the SMS is away.
  final PhoneVerification? verification;

  String get e164 => toE164(nationalDigits, region);

  bool get isNumberComplete => isCompleteNumber(nationalDigits, region);

  SignupDraft copyWith({
    DialRegion? region,
    String? nationalDigits,
    DateTime? consentAcceptedAt,
    int? termsVersion,
    int? privacyVersion,
    PhoneVerification? verification,
  }) {
    return SignupDraft(
      region: region ?? this.region,
      nationalDigits: nationalDigits ?? this.nationalDigits,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
      termsVersion: termsVersion ?? this.termsVersion,
      privacyVersion: privacyVersion ?? this.privacyVersion,
      verification: verification ?? this.verification,
    );
  }
}

final signupDraftProvider =
    NotifierProvider<SignupDraftController, SignupDraft>(
  SignupDraftController.new,
);

class SignupDraftController extends Notifier<SignupDraft> {
  @override
  SignupDraft build() => const SignupDraft();

  void setRegion(DialRegion region) {
    // Re-normalise the existing digits: national lengths differ between
    // regions, so a number typed for one may need truncating for another.
    final digits = normaliseNationalDigits(state.nationalDigits, region);
    state = state.copyWith(region: region, nationalDigits: digits);
  }

  void setNationalDigits(String digits) =>
      state = state.copyWith(nationalDigits: digits);

  void recordConsent({required int termsVersion, required int privacyVersion}) {
    state = state.copyWith(
      consentAcceptedAt: DateTime.now(),
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
    );
  }

  void setVerification(PhoneVerification verification) =>
      state = state.copyWith(verification: verification);

  void reset() => state = const SignupDraft();
}
