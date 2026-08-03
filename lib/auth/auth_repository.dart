/// The single seam between Daala and Firebase Auth / Firestore for identity.
///
/// Everything the auth screens do goes through here so the widgets stay free of
/// SDK types and the flow can be reasoned about in one place.
///
/// ## The identity contract
///
/// A phone number is the primary identifier and Firebase Auth guarantees it is
/// unique — there is no phone-to-user index collection, because one would only
/// duplicate that guarantee while handing anyone who can read it a user
/// enumeration oracle.
///
/// The email address is a **second credential on the same account**, never a
/// second account. When a user opens their sign-in link while already signed
/// in, [completeEmailLink] calls `linkWithCredential`, binding the email to the
/// existing uid. Skipping that link is the defect that splits one person into
/// two accounts with two wallets — see CLAUDE.md § Phase 2.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'legal.dart';
import 'user_profile.dart';

/// A failure worth showing the user, already phrased in plain language.
///
/// DESIGN.md has no red and no alarm colour: errors are sentences. Every
/// message here is written to be read at a glance in daylight by someone who
/// may not be a confident reader.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code, this.canRetry = true});

  final String message;
  final String? code;
  final bool canRetry;

  @override
  String toString() => 'AuthFailure($code): $message';
}

/// Translates a [FirebaseAuthException] into something a person can act on.
AuthFailure describeAuthError(Object error) {
  if (error is AuthFailure) return error;
  if (error is! FirebaseException) {
    return const AuthFailure(
      "Something went wrong on our side. Please try again.",
    );
  }
  switch (error.code) {
    case 'invalid-phone-number':
      return const AuthFailure(
        "That number doesn't look right. Check it and try again.",
      );
    case 'invalid-verification-code':
      return const AuthFailure(
        "That code doesn't match. Check the SMS and try again.",
      );
    case 'session-expired':
    case 'expired-action-code':
      return const AuthFailure(
        'That code has expired. Tap "Resend" to get a new one.',
      );
    case 'invalid-action-code':
      return const AuthFailure(
        'That link has already been used or has expired. Send a new one.',
      );
    case 'too-many-requests':
      return const AuthFailure(
        "Too many tries. Wait a few minutes and try again.",
        canRetry: false,
      );
    case 'quota-exceeded':
      return const AuthFailure(
        "We can't send codes right now. Please try again a little later.",
        canRetry: false,
      );
    case 'credential-already-in-use':
    case 'email-already-in-use':
      // Carries the code so callers can route to the conflict screen rather
      // than only printing the sentence.
      return AuthFailure(
        'That email is already on another Daala account. Use a different one, '
        'or sign in with that account instead.',
        canRetry: false,
        code: error.code,
      );
    case 'network-request-failed':
    case 'unavailable':
      return const AuthFailure(
        "You're offline. Check your connection and try again.",
      );
    case 'permission-denied':
      return const AuthFailure(
        "We couldn't save that. Please try again.",
      );
    case 'operation-not-allowed':
      return const AuthFailure(
        "This sign-in method isn't available right now.",
        canRetry: false,
      );
    default:
      // The code is carried either way; in debug builds it is also shown, so a
      // first-time failure names itself instead of needing logcat.
      return AuthFailure(
        kDebugMode
            ? 'Something went wrong. Please try again. [${error.code}]'
            : 'Something went wrong. Please try again.',
        code: error.code,
      );
  }
}

/// Handle returned by [AuthRepository.startPhoneVerification] once the SMS is
/// on its way, carrying what the OTP screen needs to verify or resend.
class PhoneVerification {
  const PhoneVerification({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;

  /// Android-only token that makes a resend a genuine resend rather than a new
  /// verification session. Passing it back avoids burning the user's quota.
  final int? resendToken;
}

/// Outcome of a completed sign-in.
class SignInResult {
  const SignInResult({required this.uid, required this.isNewUser});

  final String uid;

  /// Straight from `additionalUserInfo.isNewUser`. This is why the flow needs
  /// no "does an account exist for this number?" query — Firebase already
  /// answered it as part of the sign-in, for free.
  final bool isNewUser;
}

/// Length of a Firebase Auth SMS code. Always six — a four-box UI can never
/// validate.
const int kOtpLength = 6;

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _contactDoc(String uid) =>
      _userDoc(uid).collection('private').doc('contact');

  CollectionReference<Map<String, dynamic>> _consents(String uid) =>
      _userDoc(uid).collection('consents');

  // ───────────────────────── Phone ─────────────────────────

  /// Sends the SMS code for [e164PhoneNumber].
  ///
  /// Completes with a [PhoneVerification] once the code is sent. On Android,
  /// Play Services may verify the device silently without any SMS at all; that
  /// path resolves through [onAutoVerified] and the returned future never
  /// completes with a verification id, so callers must handle both.
  Future<PhoneVerification> startPhoneVerification({
    required String e164PhoneNumber,
    required void Function(SignInResult result) onAutoVerified,
    int? resendToken,
  }) {
    final completer = Completer<PhoneVerification>();

    _auth.verifyPhoneNumber(
      phoneNumber: e164PhoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android instant/auto-retrieval. Sign in without troubling the user.
        try {
          final result = await _signInWithCredential(credential);
          onAutoVerified(result);
        } catch (_) {
          // Fall through to manual entry; the OTP screen is already up.
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(describeAuthError(error));
        }
      },
      codeSent: (verificationId, token) {
        if (!completer.isCompleted) {
          completer.complete(PhoneVerification(
            verificationId: verificationId,
            phoneNumber: e164PhoneNumber,
            resendToken: token,
          ));
        }
      },
      codeAutoRetrievalTimeout: (_) {
        // The code stays valid; only auto-retrieval stopped listening.
      },
    );

    return completer.future;
  }

  /// Verifies the six-digit [smsCode] against [verificationId].
  Future<SignInResult> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _signInWithCredential(credential);
  }

  /// Attaches a verified phone credential to the account already signed in —
  /// the email-first signup path, where an email link created a uid that has no
  /// primary credential on it yet.
  ///
  /// The interesting case is a number that **already owns an account**. Because
  /// the phone is the primary credential, that older account is the real one and
  /// the uid we are standing in is a throwaway the email link minted seconds
  /// ago. So the stray is deleted and the phone credential is used to sign in
  /// properly, rather than leaving the person on a duplicate account with a
  /// second wallet — the exact defect the identity contract exists to prevent.
  ///
  /// The email is **carried across** that swap rather than dropped: the address
  /// is mirrored onto the adopted account's contact record immediately, and a
  /// fresh sign-in link is sent so it becomes a real Auth credential when
  /// opened. It cannot be linked outright — the link that got us here is
  /// single-use and already spent, and Firebase will not attach an email
  /// credential without a fresh proof of ownership.
  Future<SignInResult> linkPhoneToCurrentUser({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final existing = _auth.currentUser;
    if (existing == null) return _signInWithCredential(credential);

    try {
      final result = await existing.linkWithCredential(credential);
      return SignInResult(uid: result.user!.uid, isNewUser: false);
    } on FirebaseAuthException catch (error) {
      if (error.code != 'credential-already-in-use' &&
          error.code != 'account-exists-with-different-credential') {
        throw describeAuthError(error);
      }
      // Read before deleting: this address is the whole reason the person
      // started here, and it must land on the account they end up in.
      final strayEmail = existing.email;
      // Guarded on the profile's absence so this can never delete a real,
      // onboarded account — only the empty uid the email link just created.
      if (await loadProfile(existing.uid) == null) {
        try {
          await existing.delete();
        } catch (_) {
          // Non-fatal. Worst case an empty uid is left behind, which owns
          // nothing and is unreachable.
        }
      }
      final adopted = await _signInWithCredential(credential);
      if (strayEmail != null && strayEmail.isNotEmpty) {
        await _carryEmailOver(uid: adopted.uid, email: strayEmail);
      }
      return adopted;
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  /// Puts [email] on the account at [uid] after an account swap.
  ///
  /// Two halves, neither of which may break the sign-in that just succeeded:
  /// the address is written to the private contact record so the app knows it
  /// straight away, and a sign-in link goes out so opening it attaches the
  /// email as a genuine second credential via [completeEmailLink].
  Future<void> _carryEmailOver({
    required String uid,
    required String email,
  }) async {
    try {
      await _contactDoc(uid).set(
        {
          'email': email,
          // Not verified *on this account* yet — that happens when the freshly
          // sent link is opened while signed in here.
          'emailVerified': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // The link below is the part that matters; a failed mirror write is
      // recovered by the next profile write.
    }
    try {
      await sendEmailSignInLink(email);
    } catch (_) {
      // Retryable from the email login screen. Never block the sign-in.
    }
  }

  Future<SignInResult> _signInWithCredential(AuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      return SignInResult(
        uid: result.user!.uid,
        isNewUser: result.additionalUserInfo?.isNewUser ?? false,
      );
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  // ───────────────────────── Email link ─────────────────────────

  /// `ActionCodeSettings` for a passwordless email link.
  ///
  /// ## Post-Dynamic-Links, deliberately
  ///
  /// Firebase Dynamic Links shut down on 25 August 2025. Email link sign-in
  /// **was not withdrawn with it** — it was migrated. The old
  /// `dynamicLinkDomain` field no longer exists in the SDK at all; [linkDomain]
  /// replaced it, and that is what this code uses. Nothing here depends on
  /// Dynamic Links.
  ///
  /// [linkDomain] must be a **Firebase Hosting custom domain on this project**
  /// (the SDK rejects the default `web.app` / `firebaseapp.com` domains for this
  /// field). Hosting then serves the App Links / Universal Links association
  /// files for it automatically, which is why `login.daala.co.za` has to live on
  /// Firebase Hosting rather than any web host.
  ///
  /// `handleCodeInApp` is what makes the link open the app rather than a web
  /// page.
  ///
  /// One capability genuinely did die with Dynamic Links: a link can no longer
  /// send someone to the store when the app isn't installed. `androidInstallApp`
  /// is therefore omitted — it would be a no-op that reads as working config.
  ActionCodeSettings _emailLinkSettings() => ActionCodeSettings(
        url: kEmailLinkContinueUrl,
        linkDomain: kEmailLinkDomain,
        handleCodeInApp: true,
        androidPackageName: kAndroidPackageName,
        androidMinimumVersion: '23',
        iOSBundleId: kIosBundleId,
      );

  /// Sends a sign-in link to [email].
  ///
  /// Called from two places with the same payload:
  ///
  /// * **Onboarding** — the address the user just typed, so that opening the
  ///   link *links* it to their phone account and marks it verified.
  /// * **Email login** — an address someone typed because they can't reach
  ///   their phone.
  ///
  /// Deliberately does not check whether the address belongs to an account. A
  /// client-side existence check leaks who is registered, and Firebase's email
  /// enumeration protection blocks it anyway. The email-login screen therefore
  /// shows the same neutral confirmation either way.
  Future<void> sendEmailSignInLink(String email) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email.trim(),
        actionCodeSettings: _emailLinkSettings(),
      );
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  /// True when [link] is a Firebase email sign-in link.
  bool isEmailSignInLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Completes the email-link journey for [email] using the opened [link].
  ///
  /// Branches on whether someone is already signed in:
  ///
  /// * **Signed in** (the onboarding case) — links the email credential onto
  ///   the current phone account. One person, one uid, two ways in. If the
  ///   email is already attached to *this* account the link is a no-op and we
  ///   treat it as success.
  /// * **Signed out** (the email-login case) — signs in with the link. If the
  ///   address was linked during onboarding this resolves to the original
  ///   account, which is the whole reason the linking step exists.
  Future<SignInResult> completeEmailLink({
    required String email,
    required String link,
  }) async {
    final credential = EmailAuthProvider.credentialWithLink(
      email: email.trim(),
      emailLink: link,
    );
    final existing = _auth.currentUser;

    if (existing != null) {
      try {
        final result = await existing.linkWithCredential(credential);
        await _markEmailVerified(result.user!.uid, email.trim());
        return SignInResult(uid: result.user!.uid, isNewUser: false);
      } on FirebaseAuthException catch (error) {
        final alreadyOurs = error.code == 'provider-already-linked' ||
            (error.code == 'email-already-in-use' &&
                existing.email == email.trim());
        if (alreadyOurs) {
          await _markEmailVerified(existing.uid, email.trim());
          return SignInResult(uid: existing.uid, isNewUser: false);
        }
        throw describeAuthError(error);
      } catch (error) {
        throw describeAuthError(error);
      }
    }

    final result = await _signInWithCredential(credential);
    if (!result.isNewUser) {
      await _markEmailVerified(result.uid, email.trim());
    }
    return result;
  }

  Future<void> _markEmailVerified(String uid, String email) async {
    try {
      await _contactDoc(uid).set(
        {
          'email': email,
          'emailVerified': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // A profile document may not exist yet (email link opened mid-onboarding).
      // The address is already on the Auth record, which is the source of
      // truth; the mirror catches up on the next profile write.
    }
  }

  // ───────────────────────── Profile ─────────────────────────

  /// Reads `users/{uid}`, or `null` when onboarding has not run.
  ///
  /// The absence of this document — not a flag on the Auth record — is what
  /// defines "needs onboarding". It survives reinstalls and stays correct if a
  /// user abandons the flow halfway.
  Future<UserProfile?> loadProfile(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return UserProfile.fromDoc(snapshot);
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  /// Writes the whole signup record in one atomic batch: public card, private
  /// contact details, and the consent evidence captured back on the phone
  /// screen.
  ///
  /// One batch means a half-written profile is impossible — the state that
  /// would otherwise strand a user in a flow they've already completed.
  Future<void> createProfile({
    required String uid,
    required UserProfile profile,
    required UserContact contact,
    required ConsentRecord consent,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(_userDoc(uid), profile.toCreateMap());
      batch.set(
        _contactDoc(uid),
        contact.toCreateMap(),
        SetOptions(merge: true),
      );
      batch.set(_consents(uid).doc(), consent.toMap());
      await batch.commit();
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  // ───────────────────────── Legal ─────────────────────────

  /// Reads `config/legal`. Falls back to [LegalTerms.fallback] rather than
  /// throwing: a user must never be blocked out of the app because a config
  /// document was unreachable on a bad connection.
  Future<LegalTerms> loadLegalTerms() async {
    try {
      final snapshot = await _firestore.collection('config').doc('legal').get();
      return LegalTerms.fromDoc(snapshot);
    } catch (_) {
      return LegalTerms.fallback;
    }
  }

  /// Records a fresh acceptance (Screen 6B) and bumps the profile's version.
  Future<void> acceptUpdatedTerms({
    required String uid,
    required ConsentRecord consent,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.update(_userDoc(uid), {'termsVersion': consent.termsVersion});
      batch.set(_consents(uid).doc(), consent.toMap());
      await batch.commit();
    } catch (error) {
      throw describeAuthError(error);
    }
  }

  Future<void> signOut() => _auth.signOut();
}

/// The domain the sign-in link itself is built on — the post-Dynamic-Links
/// replacement for `dynamicLinkDomain`.
///
/// Must be a **Firebase Hosting custom domain on the `daala-69a44` project**.
/// The SDK rejects the default `web.app` / `firebaseapp.com` domains here, and
/// Hosting is what serves the `assetlinks.json` and `apple-app-site-association`
/// files that let the app intercept the link.
///
/// ⚠️ **Setting this alone is not enough.** The Auth backend also has to be told
/// to generate links on this domain, via an Admin SDK call that has no console
/// equivalent:
///
/// ```js
/// await getAuth().projectConfigManager().updateProjectConfig({
///   mobileLinksConfig: { domain: 'login.daala.co.za' },
/// });
/// ```
///
/// Until that runs, links are still generated on the old default and the app
/// never sees them. See PHASE2-SETUP.md step 5.
const String kEmailLinkDomain = 'login.daala.co.za';

/// Where the user lands after the link is validated. Must sit on
/// [kEmailLinkDomain] and be listed under Authentication → Authorised domains.
const String kEmailLinkContinueUrl =
    'https://login.daala.co.za/auth/email-link';

const String kAndroidPackageName = 'za.co.daala.daala';
const String kIosBundleId = 'za.co.daala.daala';
