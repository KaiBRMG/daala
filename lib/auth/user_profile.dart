/// Firestore user models.
///
/// The record is deliberately split across two documents:
///
/// * `users/{uid}` — the **public card**. Every gig row, offer, and chat header
///   needs the poster's name, rating, and verification badge, so this document
///   is readable by any signed-in user. It carries no contact details and no
///   date of birth.
/// * `users/{uid}/private/contact` — the **PII**. Email, phone, full surname,
///   and date of birth, readable and writable by the owner alone.
///
/// The split is what keeps POPIA-sensitive fields off other people's devices
/// while still letting a gig list render from one small document per person
/// (DESIGN.md's "surface people on every list" requirement costs one cheap read,
/// not a full profile fetch).
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Which side of the marketplace the user says they came for. Both sides stay
/// available to every account — this only seeds the Home screen's default
/// Earn⇄Browse position and the first-run recommendations.
enum UserGoal {
  makeMoney('make_money', 'Make Money'),
  getThingsDone('get_things_done', 'Get Things Done');

  const UserGoal(this.wireName, this.label);

  /// Stable Firestore value. Never persist `name` — renaming the enum would
  /// silently orphan every existing document.
  final String wireName;
  final String label;

  static UserGoal? fromWire(String? value) {
    for (final goal in UserGoal.values) {
      if (goal.wireName == value) return goal;
    }
    return null;
  }
}

/// `users/{uid}` — public, readable by any signed-in user.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastInitial,
    required this.goal,
    this.photoPath,
    this.suburb,
    this.verified = false,
    this.ratingAverage,
    this.ratingCount = 0,
    this.gigsCompleted = 0,
    this.createdAt,
    this.termsVersion,
  });

  final String uid;
  final String firstName;

  /// Only the initial is public. Full surname lives in the private document —
  /// a marketplace has no reason to broadcast a stranger's full legal name.
  final String lastInitial;
  final UserGoal goal;
  final String? photoPath;
  final String? suburb;
  final bool verified;
  final double? ratingAverage;
  final int ratingCount;
  final int gigsCompleted;
  final DateTime? createdAt;

  /// Version of the Terms this user last accepted. Compared against
  /// `config/legal` at launch to decide whether Screen 6B is owed.
  final int? termsVersion;

  /// `Marlo T.` — the form every list row and chat header uses.
  String get displayName =>
      lastInitial.isEmpty ? firstName : '$firstName $lastInitial.';

  /// Initials for [InitialsAvatar]. Falls back to one letter rather than
  /// rendering an empty circle.
  String get initials {
    final first = firstName.isEmpty ? '' : firstName[0].toUpperCase();
    final last = lastInitial.isEmpty ? '' : lastInitial.toUpperCase();
    final combined = '$first$last';
    return combined.isEmpty ? '?' : combined;
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserProfile(
      uid: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastInitial: data['lastInitial'] as String? ?? '',
      goal: UserGoal.fromWire(data['goal'] as String?) ?? UserGoal.getThingsDone,
      photoPath: data['photoPath'] as String?,
      suburb: data['suburb'] as String?,
      verified: data['verified'] as bool? ?? false,
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble(),
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      gigsCompleted: (data['gigsCompleted'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      termsVersion: (data['termsVersion'] as num?)?.toInt(),
    );
  }

  /// Fields written at signup. Counters and `verified` are omitted on purpose —
  /// security rules forbid the client from setting them, and later phases move
  /// them under server control.
  Map<String, dynamic> toCreateMap() => {
        'firstName': firstName,
        'lastInitial': lastInitial,
        'goal': goal.wireName,
        'verified': false,
        'ratingCount': 0,
        'gigsCompleted': 0,
        'termsVersion': termsVersion,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// `users/{uid}/private/contact` — owner-only PII.
class UserContact {
  const UserContact({
    required this.lastName,
    required this.dateOfBirth,
    this.email,
    this.phoneNumber,
    this.emailVerified = false,
  });

  final String lastName;
  final DateTime dateOfBirth;

  /// Collected at onboarding as an unverified address. It becomes a real
  /// sign-in method only once the user opens the link and it is *linked* to
  /// this account (see [AuthRepository.completeEmailLink]).
  final String? email;
  final String? phoneNumber;
  final bool emailVerified;

  factory UserContact.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return UserContact(
      lastName: data['lastName'] as String? ?? '',
      dateOfBirth:
          (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime(1900),
      email: data['email'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toCreateMap() => {
        'lastName': lastName,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'emailVerified': emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// The minimum age Daala accepts.
///
/// Escrow (TradeSafe, Phase 7) and KYC (VerifyNow, Phase 8) both require a
/// legally contracting adult, and POPIA treats a child's personal information
/// as a special category needing guardian consent. Enforcing it at onboarding
/// is far cheaper than discovering it at first payout.
const int kMinimumAge = 18;

/// True when [dob] puts the person at [kMinimumAge] or older today.
bool isOfAge(DateTime dob, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final eighteenth = DateTime(dob.year + kMinimumAge, dob.month, dob.day);
  return !eighteenth.isAfter(today);
}

/// Validates a `DD` / `MM` / `YYYY` triple, returning the date or `null`.
///
/// Rejects impossible calendar dates (31 February) by round-tripping through
/// [DateTime], which normalises overflow rather than throwing.
DateTime? parseBirthDate(String day, String month, String year) {
  final d = int.tryParse(day);
  final m = int.tryParse(month);
  final y = int.tryParse(year);
  if (d == null || m == null || y == null) return null;
  if (year.length != 4 || m < 1 || m > 12 || d < 1 || d > 31) return null;
  if (y < 1900 || y > DateTime.now().year) return null;
  final date = DateTime(y, m, d);
  if (date.day != d || date.month != m || date.year != y) return null;
  return date;
}
