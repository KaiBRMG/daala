/// Compact summary of a listing's poster (Consumer or Merchant) — the
/// cross-feature "Poster summary" type used on cards, detail screens,
/// offers, bookings and chat.
class PosterSummary {
  const PosterSummary({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.ratingAvg,
    required this.reviewCount,
    required this.isVerified,
    this.memberSince,
    this.jobsCompleted,
    this.completionRate,
    this.responseTimeLabel,
  });

  final String id;
  final String displayName;

  /// Phase 1: never loaded over the network — avatars render as initials.
  final String? avatarUrl;
  final double ratingAvg;
  final int reviewCount;
  final bool isVerified;
  final String? memberSince;
  final int? jobsCompleted;

  /// Percentage 0–100.
  final int? completionRate;
  final String? responseTimeLabel;
}
