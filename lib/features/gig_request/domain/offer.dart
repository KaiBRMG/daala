import '../../../core/models/poster_summary.dart';

/// A Merchant's bid on a Gig Request (DESIGN.md §3.6 data requirements).
class Offer {
  const Offer({
    required this.id,
    required this.merchant,
    required this.amountZarMinor,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final PosterSummary merchant;
  final int amountZarMinor;
  final String message;
  final DateTime createdAt;
}
