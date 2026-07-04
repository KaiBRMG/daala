import '../../../core/mock/mock_feed_store.dart';
import '../../../core/mock/mock_posters.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/models/gig_summary.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/gig_request.dart';
import '../domain/gig_request_draft.dart';
import '../domain/gig_request_repository.dart';
import '../domain/offer.dart';

/// In-memory Gig Request fixtures. IDs line up with core/mock feed
/// summaries (`gr-*`).
class MockGigRequestRepository implements GigRequestRepository {
  MockGigRequestRepository(this._feedStore);

  final MockFeedStore _feedStore;

  final Map<String, GigRequest> _requests = {
    'gr-1': GigRequest(
      id: 'gr-1',
      title: 'Fix a leaking kitchen pipe',
      statusEnum: LifecycleState.open,
      budgetZarMinor: 45000,
      category: GigCategory.plumbing,
      description:
          'The pipe under my kitchen sink has been dripping for a week '
          'and the cupboard is getting damaged. I need someone to replace '
          'the joint or the section of pipe. Parts can be bought at the '
          'hardware store two streets away.',
      suburb: 'Khayelitsha',
      whenNeededLabel: 'This week',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      photoCount: 2,
      offerCount: 3,
      poster: MockPosters.consumerNomvula,
    ),
    'gr-2': GigRequest(
      id: 'gr-2',
      title: 'Move a 2-bedroom flat to Bellville',
      statusEnum: LifecycleState.open,
      budgetZarMinor: 125000,
      category: GigCategory.moving,
      description:
          'Moving from Goodwood to Bellville on 12 July. Furniture '
          'includes two beds, a couch, fridge, washing machine and about '
          '15 boxes. Ground floor on both sides. Need a bakkie or small '
          'truck and two pairs of hands.',
      suburb: 'Goodwood',
      whenNeededLabel: 'On 12 Jul',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      photoCount: 0,
      offerCount: 4,
      poster: MockPosters.me,
    ),
    'gr-3': GigRequest(
      id: 'gr-3',
      title: 'Maths tutoring for Grade 10 learner',
      statusEnum: LifecycleState.open,
      budgetZarMinor: 30000,
      category: GigCategory.tutoring,
      description:
          'My son needs help with Grade 10 mathematics — algebra and '
          'trigonometry especially. Ideally two sessions a week in the '
          'afternoons. Online sessions are fine too.',
      suburb: 'Rondebosch',
      whenNeededLabel: 'Flexible',
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
      photoCount: 0,
      offerCount: 0,
      poster: MockPosters.consumerDavid,
    ),
    'gr-4': GigRequest(
      id: 'gr-4',
      title: 'Garden cleanup and lawn mowing',
      statusEnum: LifecycleState.open,
      budgetZarMinor: 60000,
      category: GigCategory.gardening,
      description:
          'The garden has become overgrown after the winter rains. Grass '
          'needs mowing, edges trimmed, and a pile of branches removed. '
          'I have a lawnmower but no trimmer.',
      suburb: 'Athlone',
      whenNeededLabel: 'Today',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      photoCount: 3,
      offerCount: 1,
      poster: MockPosters.consumerZanele,
    ),
  };

  final Map<String, List<Offer>> _offers = {
    'gr-1': [
      Offer(
        id: 'of-1',
        merchant: MockPosters.merchantSipho,
        amountZarMinor: 42000,
        message: 'I can come this Thursday morning. Price includes '
            'labour; parts billed at cost after we look together.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Offer(
        id: 'of-2',
        merchant: MockPosters.merchantJohan,
        amountZarMinor: 48000,
        message: 'Available tomorrow. 20 years plumbing experience, '
            'work guaranteed for 6 months.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Offer(
        id: 'of-3',
        merchant: MockPosters.merchantAyesha,
        amountZarMinor: 45000,
        message: 'Happy to match your budget. I live nearby and can '
            'start today if the parts are available.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ],
    'gr-2': [
      Offer(
        id: 'of-4',
        merchant: MockPosters.merchantJohan,
        amountZarMinor: 110000,
        message: 'I have a 1.5-ton bakkie with a canopy and a helper. '
            'We can do the whole move in one morning.',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      Offer(
        id: 'of-5',
        merchant: MockPosters.merchantSipho,
        amountZarMinor: 125000,
        message: 'Full-service move with blankets and straps for the '
            'furniture. Two helpers included.',
        createdAt: DateTime.now().subtract(const Duration(hours: 16)),
      ),
      Offer(
        id: 'of-6',
        merchant: MockPosters.merchantAyesha,
        amountZarMinor: 98000,
        message: 'Best price for a single trip. I can also help pack '
            'the boxes the evening before at no extra cost.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Offer(
        id: 'of-7',
        merchant: MockPosters.merchantLerato,
        amountZarMinor: 135000,
        message: 'Premium option — closed truck, insured goods in '
            'transit, three-person crew.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ],
    'gr-4': [
      Offer(
        id: 'of-8',
        merchant: MockPosters.merchantLerato,
        amountZarMinor: 55000,
        message: 'I bring my own trimmer and can remove the branches '
            'with my trailer. Available this afternoon.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
  };

  final Set<String> _submittedOfferGigIds = {};
  int _nextId = 5;

  @override
  Future<GigRequest> getById(String id) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    final request = _requests[id];
    if (request == null) throw GigRequestNotFoundException(id);
    return request.copyWith(
        viewerHasSubmittedOffer: _submittedOfferGigIds.contains(id));
  }

  @override
  Future<List<Offer>> offersFor(String gigRequestId) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    return DebugFlags.maybeEmpty(
        List.unmodifiable(_offers[gigRequestId] ?? const <Offer>[]));
  }

  @override
  Future<void> submitOffer({
    required String gigRequestId,
    required int amountZarMinor,
    required String message,
  }) async {
    await mockNetworkDelay();
    final offers = _offers.putIfAbsent(gigRequestId, () => []);
    offers.add(Offer(
      id: 'of-${DateTime.now().millisecondsSinceEpoch}',
      merchant: MockPosters.me,
      amountZarMinor: amountZarMinor,
      message: message,
      createdAt: DateTime.now(),
    ));
    _submittedOfferGigIds.add(gigRequestId);
    final request = _requests[gigRequestId];
    if (request != null) {
      _requests[gigRequestId] =
          request.copyWith(offerCount: request.offerCount + 1);
    }
  }

  @override
  Future<String> acceptOffer({
    required String gigRequestId,
    required String offerId,
  }) async {
    await mockNetworkDelay();
    // Phase 1: accepting always lands on the mock consumer booking.
    return 'b-1';
  }

  @override
  Future<GigRequest> create(GigRequestDraft draft) async {
    await mockNetworkDelay();
    final id = 'gr-${_nextId++}';
    final request = GigRequest(
      id: id,
      title: draft.title,
      statusEnum: LifecycleState.open,
      budgetZarMinor: draft.budgetZarMinor ?? 0,
      category: draft.category ?? GigCategory.other,
      description: draft.description,
      suburb: draft.locationType == LocationType.online
          ? 'Online'
          : draft.address,
      whenNeededLabel: draft.whenType?.label ?? WhenType.flexible.label,
      createdAt: DateTime.now(),
      photoCount: draft.photoCount,
      offerCount: 0,
      poster: MockPosters.me,
    );
    _requests[id] = request;
    _feedStore.add(GigSummary(
      id: id,
      listingType: ListingType.gigRequest,
      title: request.title,
      category: request.category,
      statusEnum: request.statusEnum,
      budgetZarMinor: request.budgetZarMinor,
      suburb: request.suburb,
      distanceKm: 0,
      timingLabel: request.whenNeededLabel,
      hasThumbnail: request.photoCount > 0,
      offerCount: 0,
      poster: request.poster,
      createdAt: request.createdAt,
    ));
    return request;
  }

  @override
  Future<void> saveDraft(GigRequestDraft draft) => mockNetworkDelay();
}
