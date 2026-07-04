import '../../../core/models/gig_category.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/poster_summary.dart';

/// Full Gig Request detail (DESIGN.md §3.2 data requirements).
class GigRequest {
  const GigRequest({
    required this.id,
    required this.title,
    required this.statusEnum,
    required this.budgetZarMinor,
    required this.category,
    required this.description,
    required this.suburb,
    required this.whenNeededLabel,
    required this.createdAt,
    required this.photoCount,
    required this.offerCount,
    required this.poster,
    this.viewerHasSubmittedOffer = false,
  });

  final String id;
  final String title;
  final LifecycleState statusEnum;
  final int budgetZarMinor;
  final GigCategory category;
  final String description;
  final String suburb;
  final String whenNeededLabel;
  final DateTime createdAt;

  /// `photos[]` — Phase 1 renders token-coloured placeholder tiles.
  final int photoCount;
  final int offerCount;
  final PosterSummary poster;

  /// Drives the "Offer submitted" (disabled) CTA state after §3.5 submit.
  final bool viewerHasSubmittedOffer;

  GigRequest copyWith({int? offerCount, bool? viewerHasSubmittedOffer}) {
    return GigRequest(
      id: id,
      title: title,
      statusEnum: statusEnum,
      budgetZarMinor: budgetZarMinor,
      category: category,
      description: description,
      suburb: suburb,
      whenNeededLabel: whenNeededLabel,
      createdAt: createdAt,
      photoCount: photoCount,
      offerCount: offerCount ?? this.offerCount,
      poster: poster,
      viewerHasSubmittedOffer:
          viewerHasSubmittedOffer ?? this.viewerHasSubmittedOffer,
    );
  }
}

class GigRequestNotFoundException implements Exception {
  const GigRequestNotFoundException(this.id);

  final String id;
}
