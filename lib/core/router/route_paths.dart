/// Route paths per DESIGN.md §2.3 — verbatim; deep-link ready for later
/// TradeSafe redirects.
abstract final class RoutePaths {
  // Auth flow (unauthenticated shell — no bottom nav)
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String intent = '/intent';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otp = '/otp';
  static const String verifyIdentity = '/verify-identity';

  // App shell tab roots
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Full-screen routes
  static const String search = '/search';
  static const String createGigRequest = '/create/gig-request';
  static const String createGigPost = '/create/gig-post';
  static const String wallet = '/wallet';
  static const String notifications = '/notifications';
  static const String settings = '/settings';

  static String gigRequest(String id) => '/gig-request/$id';
  static String makeOffer(String id) => '/gig-request/$id/offer';
  static String reviewOffers(String id) => '/gig-request/$id/offers';
  static String gigPost(String id) => '/gig-post/$id';
  static String merchant(String id) => '/merchant/$id';
  static String booking(String id) => '/booking/$id';
  static String evidence(String id) => '/booking/$id/evidence';
  static String leaveReview(String id) => '/booking/$id/review';
  static String chatThread(String threadId) => '/messages/$threadId';
}
