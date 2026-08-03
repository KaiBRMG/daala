import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'screens/auth/email_link_handler_screen.dart';
import 'screens/auth/email_conflict_screen.dart';
import 'screens/auth/email_link_sent_screen.dart';
import 'screens/auth/email_login_screen.dart';
import 'screens/auth/link_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/phone_login_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/terms_update_screen.dart';
import 'screens/auth/welcome_carousel_screen.dart';
import 'screens/booking_edit_screen.dart';
import 'screens/gig_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/my_gigs_screen.dart';
import 'screens/post_gig_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/wallet_screen.dart';
import 'widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Routes that are part of getting in, and must stay reachable while signed out.
const Set<String> _authRoutes = {
  '/welcome',
  '/auth/phone',
  '/auth/verify',
  '/auth/email',
  '/auth/email-sent',
};

/// The two paths an email sign-in link can arrive on, both exempt from every
/// redirect: they land in any session state and have to be allowed to do their
/// work.
///
/// `/__/auth/links` is Firebase's own generated link path since the Dynamic
/// Links shutdown — fixed, not configurable, and the one that actually carries
/// the `oobCode`. `/auth/email-link` is our continue URL.
const List<String> _emailLinkRoutes = ['/__/auth/links', '/auth/email-link'];

bool _isEmailLinkRoute(String location) =>
    _emailLinkRoutes.any(location.startsWith);

/// The two screens that attach a phone number to an email-first account. Both
/// have to stay reachable while the session is [NeedsPhone], and both have to be
/// bounced out of once it isn't.
const Set<String> _linkPhoneRoutes = {'/auth/link-phone', '/auth/link-verify'};

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: ref.watch(sessionRefreshProvider),
    redirect: (context, state) {
      final incoming = state.uri.path;
      final onEmailLink = _isEmailLinkRoute(incoming);

      // Hands-off while the handler is still spending the link.
      if (onEmailLink && !ref.read(emailLinkHandledProvider)) return null;

      // Once it's spent, the link route is no longer a place anyone can stay.
      // Standing in for it with `/splash` means every session state below
      // resolves to a real destination instead of falling through to `null`
      // and pinning the user on the handler.
      final location = onEmailLink ? '/splash' : incoming;

      final session = ref.read(sessionProvider);
      final introSeen = ref.read(introSeenProvider).value;
      final splashFloorDone = ref.read(splashFloorProvider).hasValue;

      // Hold on the splash until identity *and* the brand-moment floor have
      // both resolved. They run in parallel, so a slow network is never made
      // slower by the floor.
      // `hasValue` rather than `!isLoading`: a refresh after onboarding keeps
      // the previous value while reloading, and bouncing back to the splash
      // mid-session would be a visible flicker.
      if (!session.hasValue || introSeen == null || !splashFloorDone) {
        return location == '/splash' ? null : '/splash';
      }

      return switch (session.value) {
        SignedOut() => _authRoutes.contains(location)
            ? null
            : (introSeen ? '/auth/phone' : '/welcome'),

        // An email link signed them into an account with no phone number on it.
        // The number is the primary credential, so it comes before onboarding.
        NeedsPhone() =>
          _linkPhoneRoutes.contains(location) ? null : '/auth/link-phone',

        // Onboarding is not skippable: a signed-in account with no profile
        // document cannot post, apply, or hold money. The conflict screen is
        // the one exception — it is reached *from* onboarding and its whole job
        // is to offer a way out of it.
        NeedsOnboarding() => location == '/auth/profile' ||
                location == '/auth/email-conflict'
            ? null
            : '/auth/profile',

        NeedsTermsUpdate() => location == '/auth/terms' ? null : '/auth/terms',

        // Fully signed in: bounce out of any auth screen, otherwise stay put.
        Ready() => location == '/splash' ||
                location == '/welcome' ||
                location == '/auth/profile' ||
                location == '/auth/terms' ||
                _linkPhoneRoutes.contains(location) ||
                _authRoutes.contains(location)
            ? '/home'
            : null,

        null => '/splash',
      };
    },
    routes: [
      // ── Auth & onboarding ──
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeCarouselScreen(),
      ),
      GoRoute(path: '/auth/phone', builder: (_, _) => const PhoneLoginScreen()),
      GoRoute(path: '/auth/verify', builder: (_, _) => const OtpScreen()),
      GoRoute(path: '/auth/email', builder: (_, _) => const EmailLoginScreen()),
      GoRoute(
        path: '/auth/email-sent',
        builder: (_, state) =>
            EmailLinkSentScreen(email: state.extra as String? ?? ''),
      ),
      // Both link paths land on the same handler. The full URL matters, not
      // just the path: `oobCode` and `mode` ride in the query string and
      // Firebase parses them out of the whole link.
      for (final path in _emailLinkRoutes)
        GoRoute(
          path: path,
          builder: (_, state) =>
              EmailLinkHandlerScreen(link: state.uri.toString()),
        ),
      // The email-first phone attachment. Separate from `/auth/phone` on
      // purpose: that screen's "Log in with Email" action would loop straight
      // back to the state that sent the user here.
      GoRoute(
        path: '/auth/link-phone',
        builder: (_, _) => const LinkPhoneScreen(),
      ),
      GoRoute(
        path: '/auth/link-verify',
        builder: (_, _) => const OtpScreen(linkToCurrentAccount: true),
      ),
      GoRoute(
        path: '/auth/email-conflict',
        builder: (_, state) =>
            EmailConflictScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/auth/profile',
        builder: (_, _) => const ProfileSetupScreen(),
      ),
      GoRoute(path: '/auth/terms', builder: (_, _) => const TermsUpdateScreen()),

      // ── The app proper ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/my-gigs', builder: (_, _) => const MyGigsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/inbox', builder: (_, _) => const InboxScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),

      // ── Pushed routes (over the shell) ──
      GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
      GoRoute(path: '/gig', builder: (_, _) => const GigDetailScreen()),
      GoRoute(path: '/post/:kind', builder: (_, _) => const PostGigScreen()),
      GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),

      // Modal sheet (transparent, shell stays visible behind the scrim).
      GoRoute(
        path: '/booking/edit',
        pageBuilder: (context, state) => CustomTransitionPage(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 220),
          child: const BookingEditScreen(),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    ],
  );
});
