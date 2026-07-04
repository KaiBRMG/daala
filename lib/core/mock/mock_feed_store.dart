import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gig_category.dart';
import '../models/gig_summary.dart';
import '../models/lifecycle_state.dart';
import '../models/listing_type.dart';
import 'mock_posters.dart';

/// Mutable in-memory feed shared across features (discovery reads it; the
/// create wizards append to it). IDs line up with the per-feature detail
/// fixtures: `gr-*` → gig_request/data, `gp-*` → gig_post/data.
class MockFeedStore {
  final List<GigSummary> gigs = [
    GigSummary(
      id: 'gr-1',
      listingType: ListingType.gigRequest,
      title: 'Fix a leaking kitchen pipe',
      category: GigCategory.plumbing,
      statusEnum: LifecycleState.open,
      budgetZarMinor: 45000,
      suburb: 'Khayelitsha',
      distanceKm: 3.2,
      timingLabel: 'This week',
      offerCount: 3,
      poster: MockPosters.consumerNomvula,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    GigSummary(
      id: 'gp-1',
      listingType: ListingType.gigPost,
      title: 'Certified electrician — CoC & repairs',
      category: GigCategory.electrical,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 55000,
      suburb: 'Mitchells Plain',
      distanceKm: 6.8,
      timingLabel: 'Available weekdays',
      hasThumbnail: true,
      offerCount: 0,
      poster: MockPosters.merchantSipho,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GigSummary(
      id: 'gr-2',
      listingType: ListingType.gigRequest,
      title: 'Move a 2-bedroom flat to Bellville',
      category: GigCategory.moving,
      statusEnum: LifecycleState.open,
      budgetZarMinor: 125000,
      suburb: 'Goodwood',
      distanceKm: 9.1,
      timingLabel: 'On 12 Jul',
      offerCount: 4,
      poster: MockPosters.me,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GigSummary(
      id: 'gp-2',
      listingType: ListingType.gigPost,
      title: 'Deep home cleaning, flats & houses',
      category: GigCategory.cleaning,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 35000,
      suburb: 'Gugulethu',
      distanceKm: 4.5,
      timingLabel: 'Available this week',
      offerCount: 0,
      poster: MockPosters.merchantLerato,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    GigSummary(
      id: 'gr-3',
      listingType: ListingType.gigRequest,
      title: 'Maths tutoring for Grade 10 learner',
      category: GigCategory.tutoring,
      statusEnum: LifecycleState.open,
      budgetZarMinor: 30000,
      suburb: 'Rondebosch',
      distanceKm: 11.4,
      timingLabel: 'Flexible',
      offerCount: 0,
      poster: MockPosters.consumerDavid,
      createdAt: DateTime.now().subtract(const Duration(hours: 26)),
    ),
    GigSummary(
      id: 'gr-4',
      listingType: ListingType.gigRequest,
      title: 'Garden cleanup and lawn mowing',
      category: GigCategory.gardening,
      statusEnum: LifecycleState.open,
      budgetZarMinor: 60000,
      suburb: 'Athlone',
      distanceKm: 5.3,
      timingLabel: 'Today',
      hasThumbnail: true,
      offerCount: 1,
      poster: MockPosters.consumerZanele,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    GigSummary(
      id: 'gp-3',
      listingType: ListingType.gigPost,
      title: 'Reliable moving & bakkie hire',
      category: GigCategory.moving,
      statusEnum: LifecycleState.active,
      priceFromZarMinor: 90000,
      suburb: 'Parow',
      distanceKm: 8.0,
      timingLabel: 'Available daily',
      hasThumbnail: true,
      offerCount: 0,
      poster: MockPosters.merchantJohan,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  void add(GigSummary gig) => gigs.insert(0, gig);
}

final mockFeedStoreProvider = Provider<MockFeedStore>((ref) => MockFeedStore());
