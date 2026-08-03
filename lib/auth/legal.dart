/// Legal terms versioning and consent capture.
///
/// `config/legal` is a single public-read document holding the current Terms
/// and Privacy versions plus their URLs. It is read once per launch and cached
/// by the Firestore SDK, so the cost is one small document — the alternative
/// (hard-coding the version in the app) means a terms change ships only with a
/// store release, which is exactly the case Screen 6B exists to handle.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Fallback used before `config/legal` resolves, or if it is missing. Keeping a
/// version of 1 here means a fresh install never blocks on the network to show
/// the consent line on the phone screen.
const int kFallbackTermsVersion = 1;

const String kTermsUrl = 'https://www.daala.co.za/terms';
const String kPrivacyUrl = 'https://www.daala.co.za/privacy';

/// `config/legal` — public read, admin-only write.
class LegalTerms {
  const LegalTerms({
    required this.termsVersion,
    required this.privacyVersion,
    required this.termsUrl,
    required this.privacyUrl,
    this.changeSummary,
  });

  final int termsVersion;
  final int privacyVersion;
  final String termsUrl;
  final String privacyUrl;

  /// Plain-language sentence shown on Screen 6B describing what changed.
  /// Written by whoever publishes the terms, not generated.
  final String? changeSummary;

  static const LegalTerms fallback = LegalTerms(
    termsVersion: kFallbackTermsVersion,
    privacyVersion: kFallbackTermsVersion,
    termsUrl: kTermsUrl,
    privacyUrl: kPrivacyUrl,
  );

  factory LegalTerms.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return fallback;
    return LegalTerms(
      termsVersion:
          (data['termsVersion'] as num?)?.toInt() ?? kFallbackTermsVersion,
      privacyVersion:
          (data['privacyVersion'] as num?)?.toInt() ?? kFallbackTermsVersion,
      termsUrl: data['termsUrl'] as String? ?? kTermsUrl,
      privacyUrl: data['privacyUrl'] as String? ?? kPrivacyUrl,
      changeSummary: data['changeSummary'] as String?,
    );
  }
}

/// One immutable acceptance event, appended to `users/{uid}/consents/{autoId}`.
///
/// A subcollection rather than a field because consent is legal evidence: you
/// need the history, not the latest value. Rules make these documents
/// create-only — nobody, including the user, may edit or delete a past
/// acceptance.
class ConsentRecord {
  const ConsentRecord({
    required this.termsVersion,
    required this.privacyVersion,
    required this.source,
    required this.acceptedAt,
  });

  final int termsVersion;
  final int privacyVersion;

  /// Where the acceptance happened: `signup` or `terms_update`.
  final String source;

  /// Captured on-device at the moment of the tap. On the phone screen the tap
  /// happens *before* there is a uid to write under, so the timestamp travels
  /// with the flow and lands on the first authenticated write. The server
  /// timestamp of the write itself is recorded separately as `recordedAt`.
  final DateTime acceptedAt;

  Map<String, dynamic> toMap() => {
        'termsVersion': termsVersion,
        'privacyVersion': privacyVersion,
        'source': source,
        'acceptedAt': Timestamp.fromDate(acceptedAt),
        'recordedAt': FieldValue.serverTimestamp(),
      };
}
