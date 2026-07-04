import '../../../core/mock/mock_feed_store.dart';
import '../../../core/mock/mock_posters.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/models/gig_summary.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/models/review.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/gig_post.dart';
import '../domain/gig_post_draft.dart';
import '../domain/gig_post_repository.dart';

/// In-memory Gig Post fixtures. IDs line up with core/mock feed
/// summaries (`gp-*`).
class MockGigPostRepository implements GigPostRepository {
  MockGigPostRepository(this._feedStore);

  final MockFeedStore _feedStore;

  final Map<String, GigPost> _posts = {
    'gp-1': GigPost(
      id: 'gp-1',
      title: 'Certified electrician — CoC & repairs',
      category: GigCategory.electrical,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 55000,
      description:
          'Registered electrician with 12 years of experience. I handle '
          'fault finding, DB board upgrades, new plugs and lights, and '
          'Certificates of Compliance for property sales. Neat work, '
          'guaranteed, with a callout included in the price.',
      mediaCount: 3,
      portfolioCount: 6,
      serviceAreaLabel: 'Mitchells Plain & surrounds',
      serviceRadiusKm: 15,
      merchant: MockPosters.merchantSipho,
      reviews: [
        Review(
          author: 'Nomvula Khumalo',
          rating: 5,
          comment: 'Sipho rewired our kitchen and issued the CoC the '
              'same week. Professional and tidy.',
          date: DateTime.now().subtract(const Duration(days: 12)),
        ),
        Review(
          author: 'David Botha',
          rating: 4,
          comment: 'Arrived on time and fixed the tripping breaker '
              'quickly. Would use again.',
          date: DateTime.now().subtract(const Duration(days: 40)),
          hasPhoto: true,
        ),
      ],
    ),
    'gp-2': GigPost(
      id: 'gp-2',
      title: 'Deep home cleaning, flats & houses',
      category: GigCategory.cleaning,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 35000,
      description:
          'Thorough top-to-bottom cleaning: kitchens, bathrooms, windows '
          'inside, skirtings and cupboard fronts. I bring my own '
          'products and equipment. End-of-lease cleans welcome.',
      mediaCount: 0,
      portfolioCount: 4,
      serviceAreaLabel: 'Gugulethu & surrounds',
      serviceRadiusKm: 10,
      merchant: MockPosters.merchantLerato,
      reviews: [
        Review(
          author: 'Zanele Mthembu',
          rating: 5,
          comment: 'The flat has never looked this good. Booked a '
              'monthly slot straight away.',
          date: DateTime.now().subtract(const Duration(days: 6)),
        ),
      ],
    ),
    'gp-3': GigPost(
      id: 'gp-3',
      title: 'Reliable moving & bakkie hire',
      category: GigCategory.moving,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 90000,
      description:
          'Bakkie with canopy plus a two-man team for small to medium '
          'moves. Blankets and straps included. Weekend moves at no '
          'extra charge.',
      mediaCount: 2,
      portfolioCount: 0,
      serviceAreaLabel: 'Parow & northern suburbs',
      serviceRadiusKm: 25,
      merchant: MockPosters.merchantJohan,
      reviews: const [],
    ),
  };

  int _nextId = 4;

  @override
  Future<GigPost> getById(String id) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    final post = _posts[id];
    if (post == null) throw GigPostNotFoundException(id);
    return post;
  }

  @override
  Future<String> book(String gigPostId) async {
    await mockNetworkDelay();
    // Phase 1: booking always lands on the mock consumer booking.
    return 'b-1';
  }

  @override
  Future<GigPost> create(GigPostDraft draft) async {
    await mockNetworkDelay();
    final id = 'gp-${_nextId++}';
    final post = GigPost(
      id: id,
      title: draft.title,
      category: draft.category ?? GigCategory.other,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: draft.priceZarMinor ?? 0,
      description: draft.description,
      mediaCount: draft.portfolioCount,
      portfolioCount: draft.portfolioCount,
      serviceAreaLabel: draft.serviceArea,
      serviceRadiusKm: 10,
      merchant: MockPosters.me,
      reviews: const [],
    );
    _posts[id] = post;
    _feedStore.add(GigSummary(
      id: id,
      listingType: ListingType.gigPost,
      title: post.title,
      category: post.category,
      statusEnum: post.statusEnum,
      priceFromZarMinor: post.priceFromZarMinor,
      suburb: post.serviceAreaLabel,
      distanceKm: 0,
      timingLabel: 'Available now',
      hasThumbnail: post.mediaCount > 0,
      offerCount: 0,
      poster: post.merchant,
      createdAt: DateTime.now(),
    ));
    return post;
  }

  @override
  Future<void> saveDraft(GigPostDraft draft) => mockNetworkDelay();
}
