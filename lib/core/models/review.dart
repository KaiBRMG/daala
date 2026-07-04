/// A review left after a completed Booking — shown on Gig Post Detail and
/// the Public Merchant Profile.
class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
    this.hasPhoto = false,
  });

  final String author;
  final int rating;
  final String comment;
  final DateTime date;

  /// Phase 1 stands in for `photo?` — rendered as a placeholder tile.
  final bool hasPhoto;
}
