/// Riverpod wiring for identity: one [Session] value that the router and every
/// auth screen read from.
///
/// Resolving the session is the app's boot-critical path, so it is kept to the
/// smallest possible number of round trips: the auth state stream (local, no
/// network), one `users/{uid}` read, and one cached `config/legal` read. Nothing
/// else gates the first frame.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'legal.dart';
import 'pending_email_store.dart';
import 'user_profile.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final pendingEmailStoreProvider =
    Provider<PendingEmailStore>((ref) => PendingEmailStore());

/// Raw Firebase auth state. Emits immediately from the persisted token, so a
/// returning user is recognised offline.
final authUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Current published legal versions. Cached by the Firestore SDK, and falls
/// back to constants when unreachable, so it can never block launch.
final legalTermsProvider = FutureProvider<LegalTerms>(
  (ref) => ref.watch(authRepositoryProvider).loadLegalTerms(),
);

/// Whether the email-link handler has finished with the link it was given.
///
/// The link routes have to be exempt from redirects while the handler works —
/// they land in any session state, including signed out, and a redirect would
/// throw the link away before it is spent. That exemption is also a trap: an
/// unconditional one means nothing can ever move the user off the handler.
///
/// So the exemption is scoped to this flag rather than made permanent, and the
/// router (not the screen) does the navigating. A screen that has to steer the
/// router by hand is a screen that strands the user the moment any await in
/// front of that steering fails to complete.
final emailLinkHandledProvider =
    NotifierProvider<EmailLinkHandledController, bool>(
  EmailLinkHandledController.new,
);

class EmailLinkHandledController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Called when a fresh, unspent link arrives.
  void rearm() => state = false;

  /// Called once the link has been spent, releasing the route to the redirect.
  void release() => state = true;
}

/// Whether the carousel has already been seen on this device.
final introSeenProvider = FutureProvider<bool>(
  (ref) => ref.watch(pendingEmailStoreProvider).introSeen(),
);

/// Holds the splash open long enough to read as a brand moment rather than a
/// flash, without ever *adding* delay to a slow boot: the router waits on the
/// session and this timer in parallel, so on a slow connection the floor costs
/// nothing.
final splashFloorProvider = FutureProvider<void>(
  (ref) => Future<void>.delayed(const Duration(milliseconds: 850)),
);

/// Where a signed-in — or signed-out — person actually stands.
sealed class Session {
  const Session();
}

/// Nobody is signed in.
class SignedOut extends Session {
  const SignedOut();
}

/// Signed in with an email link on an address that had no account, so Firebase
/// minted a fresh uid carrying an email and nothing else.
///
/// This state is unavoidable rather than a bug: `sendSignInLinkToEmail` cannot
/// be made conditional on an account existing (that check is exactly what email
/// enumeration protection forbids), and opening an unknown address's link
/// creates the account. The phone number is the primary credential, so it has
/// to be attached to this uid before onboarding can run.
class NeedsPhone extends Session {
  const NeedsPhone(this.uid, {this.email});

  final String uid;
  final String? email;
}

/// Signed in, but `users/{uid}` does not exist yet: onboarding never finished.
/// Derived from the document's absence rather than a local flag, so it survives
/// reinstalls and half-finished signups.
class NeedsOnboarding extends Session {
  const NeedsOnboarding(this.uid, {this.phoneNumber});

  final String uid;
  final String? phoneNumber;
}

/// Signed in and onboarded, but the Terms have moved on since they last agreed.
class NeedsTermsUpdate extends Session {
  const NeedsTermsUpdate(this.profile, this.terms);

  final UserProfile profile;
  final LegalTerms terms;
}

/// Signed in, onboarded, current on terms — the app proper.
class Ready extends Session {
  const Ready(this.profile);

  final UserProfile profile;
}

final sessionProvider = AsyncNotifierProvider<SessionController, Session>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<Session> {
  @override
  Future<Session> build() async {
    final user = await ref.watch(authUserProvider.future);
    if (user == null) return const SignedOut();

    final repository = ref.watch(authRepositoryProvider);
    final profile = await repository.loadProfile(user.uid);
    if (profile == null) {
      // No profile *and* no phone: an email link signed them into a uid that
      // has no primary credential yet. Collect the number before onboarding.
      final phoneNumber = user.phoneNumber;
      if (phoneNumber == null || phoneNumber.isEmpty) {
        return NeedsPhone(user.uid, email: user.email);
      }
      return NeedsOnboarding(user.uid, phoneNumber: phoneNumber);
    }

    final terms = await ref.watch(legalTermsProvider.future);
    if ((profile.termsVersion ?? 0) < terms.termsVersion) {
      return NeedsTermsUpdate(profile, terms);
    }
    return Ready(profile);
  }

  /// Re-reads the profile after onboarding or a terms acceptance.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    await ref.read(pendingEmailStoreProvider).clearPendingEmail();
  }
}

/// Bridges the three providers the router's redirect reads to
/// `GoRouter.refreshListenable`.
///
/// GoRouter needs a synchronous `Listenable`; Riverpod hands us async values.
/// Subscribing here does double duty: it re-runs redirects when any of them
/// settles, *and* it keeps them alive, so `ref.read` inside the redirect never
/// sees an uninitialised provider.
class SessionRefreshNotifier extends ChangeNotifier {
  SessionRefreshNotifier(Ref ref) {
    _subscriptions = [
      ref.listen<AsyncValue<Session>>(
        sessionProvider,
        (_, _) => notifyListeners(),
        fireImmediately: true,
      ),
      ref.listen<AsyncValue<bool>>(
        introSeenProvider,
        (_, _) => notifyListeners(),
        fireImmediately: true,
      ),
      ref.listen<AsyncValue<void>>(
        splashFloorProvider,
        (_, _) => notifyListeners(),
        fireImmediately: true,
      ),
      // Flipping this is what releases the email-link routes back to the normal
      // redirect, so the router has to be told when it changes.
      ref.listen<bool>(
        emailLinkHandledProvider,
        (_, _) => notifyListeners(),
        fireImmediately: true,
      ),
    ];
    ref.onDispose(() {
      for (final subscription in _subscriptions) {
        subscription.close();
      }
    });
  }

  late final List<ProviderSubscription<Object?>> _subscriptions;
}

final sessionRefreshProvider = Provider<SessionRefreshNotifier>((ref) {
  final notifier = SessionRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
