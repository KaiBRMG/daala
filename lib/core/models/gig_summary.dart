import 'gig_category.dart';
import 'lifecycle_state.dart';
import 'listing_type.dart';
import 'poster_summary.dart';

/// Feed-card data for a mixed list of Gig Requests and Gig Posts
/// (DESIGN.md §3.1 "Data & content requirements").
class GigSummary {
  const GigSummary({
    required this.id,
    required this.listingType,
    required this.title,
    required this.category,
    required this.statusEnum,
    this.budgetZarMinor,
    this.priceFromZarMinor,
    required this.suburb,
    required this.distanceKm,
    required this.timingLabel,
    this.hasThumbnail = false,
    required this.offerCount,
    required this.poster,
    required this.createdAt,
  });

  final String id;
  final ListingType listingType;
  final String title;
  final GigCategory category;
  final LifecycleState statusEnum;

  /// Gig Request budget, in ZAR minor units.
  final int? budgetZarMinor;

  /// Gig Post "from R…" price, in ZAR minor units.
  final int? priceFromZarMinor;
  final String suburb;
  final double distanceKm;
  final String timingLabel;

  /// Phase 1 stands in for `thumbnailUrl?` — rendered as a token-coloured
  /// placeholder box (no network images).
  final bool hasThumbnail;
  final int offerCount;
  final PosterSummary poster;
  final DateTime createdAt;
}
