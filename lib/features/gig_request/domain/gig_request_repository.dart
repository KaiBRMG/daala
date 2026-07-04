import 'gig_request.dart';
import 'gig_request_draft.dart';
import 'offer.dart';

/// Gig Request repository interface — mocked in Phase 1, Firestore later.
abstract class GigRequestRepository {
  Future<GigRequest> getById(String id);

  Future<List<Offer>> offersFor(String gigRequestId);

  Future<void> submitOffer({
    required String gigRequestId,
    required int amountZarMinor,
    required String message,
  });

  /// Accepting an Offer creates a Booking and moves funds into Escrow.
  /// Returns the new booking id.
  Future<String> acceptOffer({
    required String gigRequestId,
    required String offerId,
  });

  /// Pushes a new mock Gig Request into the in-memory repo (and feed).
  Future<GigRequest> create(GigRequestDraft draft);

  Future<void> saveDraft(GigRequestDraft draft);
}
