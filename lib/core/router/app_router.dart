import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/intent_select_screen.dart';
import '../../features/auth/presentation/log_in_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/verify_identity_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/evidence_upload_screen.dart';
import '../../features/booking/presentation/leave_review_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/discovery/presentation/home_screen.dart';
import '../../features/discovery/presentation/search_screen.dart';
import '../../features/gig_post/presentation/create_gig_post_wizard_screen.dart';
import '../../features/gig_post/presentation/gig_post_detail_screen.dart';
import '../../features/gig_request/presentation/create_gig_request_wizard_screen.dart';
import '../../features/gig_request/presentation/gig_request_detail_screen.dart';
import '../../features/gig_request/presentation/make_offer_screen.dart';
import '../../features/gig_request/presentation/review_offers_screen.dart';
import '../../features/messaging/presentation/chat_thread_screen.dart';
import '../../features/messaging/presentation/messages_screen.dart';
import '../../features/profile/presentation/merchant_profile_screen.dart';
import '../../features/profile/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../mock/mock_session.dart';
import 'app_shell.dart';
import 'route_paths.dart';

const Set<String> _authPaths = {
  RoutePaths.splash,
  RoutePaths.onboarding,
  RoutePaths.intent,
  RoutePaths.login,
  RoutePaths.signup,
  RoutePaths.otp,
  RoutePaths.verifyIdentity,
};

/// GoRouter config per DESIGN.md §2.3. Phase 1 auth guard is the mock
/// session flag — no Firebase.
final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: session,
    redirect: (context, state) {
      final inAuthFlow = _authPaths.contains(state.matchedLocation);
      if (!session.signedIn && !inAuthFlow) return RoutePaths.splash;
      return null;
    },
    routes: [
      // ── Auth flow (no bottom nav) ──
      GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(
          path: RoutePaths.intent,
          builder: (context, state) => const IntentSelectScreen()),
      GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LogInScreen()),
      GoRoute(
          path: RoutePaths.signup,
          builder: (context, state) => const SignUpScreen()),
      GoRoute(
          path: RoutePaths.otp,
          builder: (context, state) =>
              OtpScreen(phone: state.uri.queryParameters['phone'])),
      GoRoute(
          path: RoutePaths.verifyIdentity,
          builder: (context, state) => const VerifyIdentityScreen()),

      // ── App shell: 4 tab branches (Post is a sheet, not a branch) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => HomeScreen(
                  initialView: state.uri.queryParameters['view']),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              builder: (context, state) => DashboardScreen(
                  initialTab: state.uri.queryParameters['tab']),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.messages,
              builder: (context, state) => const MessagesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),

      // ── Full-screen routes (root navigator — detail screens carry their
      //    own sticky CTA bars) ──
      GoRoute(
          path: RoutePaths.search,
          builder: (context, state) => const SearchScreen()),
      GoRoute(
        path: '/gig-request/:id',
        builder: (context, state) =>
            GigRequestDetailScreen(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'offer',
            builder: (context, state) =>
                MakeOfferScreen(gigRequestId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'offers',
            builder: (context, state) => ReviewOffersScreen(
                gigRequestId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/gig-post/:id',
        builder: (context, state) =>
            GigPostDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/merchant/:id',
        builder: (context, state) =>
            MerchantProfileScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
          path: RoutePaths.createGigRequest,
          builder: (context, state) => const CreateGigRequestWizardScreen()),
      GoRoute(
          path: RoutePaths.createGigPost,
          builder: (context, state) => const CreateGigPostWizardScreen()),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) =>
            BookingScreen(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'evidence',
            builder: (context, state) => EvidenceUploadScreen(
                bookingId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'review',
            builder: (context, state) =>
                LeaveReviewScreen(bookingId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/messages/:threadId',
        builder: (context, state) =>
            ChatThreadScreen(threadId: state.pathParameters['threadId']!),
      ),
      GoRoute(
          path: RoutePaths.wallet,
          builder: (context, state) => const WalletScreen()),
      GoRoute(
          path: RoutePaths.notifications,
          builder: (context, state) => const NotificationsScreen()),
      GoRoute(
          path: RoutePaths.settings,
          builder: (context, state) => const SettingsScreen()),
    ],
  );
});
