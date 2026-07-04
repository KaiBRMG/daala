import '../../../core/mock/mock_posters.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/models/review.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/app_notification.dart';
import '../domain/merchant_profile.dart';
import '../domain/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  static final Map<String, MerchantProfile> _profiles = {
    'm-1': MerchantProfile(
      summary: MockPosters.merchantSipho,
      categories: const [GigCategory.electrical, GigCategory.plumbing],
      serviceArea: 'Mitchells Plain & surrounds',
      bio: 'Registered electrician with 12 years on the tools. I take '
          'pride in neat, compliant work and honest quotes. Weekends '
          'available for emergencies.',
      portfolioCount: 6,
      reviews: [
        Review(
          author: 'Nomvula Khumalo',
          rating: 5,
          comment: 'Rewired our kitchen and issued the CoC the same '
              'week. Professional and tidy.',
          date: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Review(
          author: 'David Botha',
          rating: 4,
          comment: 'Fixed the tripping breaker quickly.',
          date: DateTime.now().subtract(const Duration(days: 40)),
        ),
        Review(
          author: 'Zanele Mthembu',
          rating: 5,
          comment: 'On time, on budget, very respectful of the house.',
          date: DateTime.now().subtract(const Duration(days: 90)),
          hasPhoto: true,
        ),
      ],
    ),
    'm-2': MerchantProfile(
      summary: MockPosters.merchantLerato,
      categories: const [GigCategory.cleaning, GigCategory.gardening],
      serviceArea: 'Gugulethu & surrounds',
      bio: 'Deep cleaning specialist — homes, flats and end-of-lease. '
          'I bring my own products and equipment.',
      portfolioCount: 4,
      reviews: [
        Review(
          author: 'Zanele Mthembu',
          rating: 5,
          comment: 'The flat has never looked this good.',
          date: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    ),
    'm-3': MerchantProfile(
      summary: MockPosters.merchantJohan,
      categories: const [GigCategory.moving],
      serviceArea: 'Parow & northern suburbs',
      bio: 'Bakkie with canopy and a two-man team for small to medium '
          'moves.',
      portfolioCount: 0,
      reviews: const [],
    ),
    'm-4': MerchantProfile(
      summary: MockPosters.merchantAyesha,
      categories: const [GigCategory.tutoring, GigCategory.other],
      serviceArea: 'Rondebosch & southern suburbs (online too)',
      bio: 'Maths and science tutor, 8 years of experience from Grade 8 '
          'to first-year university. Patient, structured lessons.',
      portfolioCount: 2,
      reviews: [
        Review(
          author: 'David Botha',
          rating: 5,
          comment: 'My son went from 48% to 71% in one term.',
          date: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    ),
  };

  static final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n-1',
      type: NotificationType.offerReceived,
      title: 'New Offer on your Gig Request',
      body: 'Ayesha Patel offered R980 on "Move a 2-bedroom flat".',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      unread: true,
      targetRoute: '/gig-request/gr-2/offers',
    ),
    AppNotification(
      id: 'n-2',
      type: NotificationType.escrow,
      title: 'Funds held in Escrow',
      body: 'R450 secured for "Fix a leaking kitchen pipe".',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unread: true,
      targetRoute: '/booking/b-1',
    ),
    AppNotification(
      id: 'n-3',
      type: NotificationType.booking,
      title: 'Booking confirmed',
      body: 'Nomvula Khumalo booked "Deep home cleaning".',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unread: false,
      targetRoute: '/booking/b-2',
    ),
    AppNotification(
      id: 'n-4',
      type: NotificationType.dispute,
      title: 'Dispute update',
      body: 'Your Dispute on "Garden cleanup" is under review.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      unread: false,
      targetRoute: '/booking/b-3',
    ),
    AppNotification(
      id: 'n-5',
      type: NotificationType.review,
      title: 'New review received',
      body: 'Ayesha Patel left you a 5-star review.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      unread: false,
      targetRoute: '/merchant/u-me',
    ),
  ];

  @override
  Future<MerchantProfile> merchantById(String id) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    final profile = _profiles[id];
    if (profile != null) return profile;

    // Consumers (and the current user) share the same public surface.
    final poster = MockPosters.byId(id);
    if (poster == null) throw MerchantProfileNotFoundException(id);
    return MerchantProfile(
      summary: poster,
      categories: const [],
      serviceArea: '—',
      bio: 'Daala member since ${poster.memberSince ?? '—'}.',
      portfolioCount: 0,
      reviews: const [],
    );
  }

  @override
  Future<List<AppNotification>> notifications() async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    return DebugFlags.maybeEmpty(_notifications);
  }
}
