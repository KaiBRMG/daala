import '../../../core/models/gig_category.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/poster_summary.dart';
import '../../../core/models/review.dart';

/// Full Gig Post detail (DESIGN.md §3.3 data requirements).
class GigPost {
  const GigPost({
    required this.id,
    required this.title,
    required this.category,
    required this.statusEnum,
    required this.priceFromZarMinor,
    required this.description,
    required this.mediaCount,
    required this.portfolioCount,
    required this.serviceAreaLabel,
    required this.serviceRadiusKm,
    required this.merchant,
    required this.reviews,
  });

  final String id;
  final String title;
  final GigCategory category;
  final LifecycleState statusEnum;
  final int priceFromZarMinor;
  final String description;

  /// `media[]` — carousel pages, rendered as placeholder boxes in Phase 1.
  final int mediaCount;

  /// Portfolio grid tiles.
  final int portfolioCount;
  final String serviceAreaLabel;
  final int serviceRadiusKm;
  final PosterSummary merchant;
  final List<Review> reviews;
}

class GigPostNotFoundException implements Exception {
  const GigPostNotFoundException(this.id);

  final String id;
}
