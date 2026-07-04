import '../../../core/models/gig_category.dart';
import '../../../core/models/poster_summary.dart';
import '../../../core/models/review.dart';

/// Public Merchant Profile — the conversion/trust surface
/// (DESIGN.md §3.10 data requirements).
class MerchantProfile {
  const MerchantProfile({
    required this.summary,
    required this.categories,
    required this.serviceArea,
    required this.bio,
    required this.portfolioCount,
    required this.reviews,
  });

  final PosterSummary summary;
  final List<GigCategory> categories;
  final String serviceArea;
  final String bio;

  /// `portfolio[]` — placeholder tiles in Phase 1.
  final int portfolioCount;
  final List<Review> reviews;
}

class MerchantProfileNotFoundException implements Exception {
  const MerchantProfileNotFoundException(this.id);

  final String id;
}
