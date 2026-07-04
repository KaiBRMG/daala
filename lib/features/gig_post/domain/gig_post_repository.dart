import 'gig_post.dart';
import 'gig_post_draft.dart';

/// Gig Post repository interface — mocked in Phase 1, Firestore later.
abstract class GigPostRepository {
  Future<GigPost> getById(String id);

  /// Booking a Gig Post creates a Booking with funds held in Escrow.
  /// Returns the new booking id.
  Future<String> book(String gigPostId);

  /// Pushes a new mock Gig Post into the in-memory repo (and feed).
  Future<GigPost> create(GigPostDraft draft);

  Future<void> saveDraft(GigPostDraft draft);
}
