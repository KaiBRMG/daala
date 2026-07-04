import 'booking.dart';

/// Booking/Escrow repository interface — mocked in Phase 1; TradeSafe
/// escrow arrives in Phase 7 behind this interface.
abstract class BookingRepository {
  Future<Booking> getById(String id);

  /// Consumer action — releases Escrow (IN_PROGRESS → COMPLETED).
  Future<Booking> markComplete(String id);

  /// Merchant action (IN_ESCROW → IN_PROGRESS).
  Future<Booking> startWork(String id);

  /// Freezes escrowed funds pending resolution (→ DISPUTED).
  Future<Booking> raiseDispute(String id);

  /// Mock evidence photo upload.
  Future<Booking> addEvidence(String id);

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
    required bool hasPhoto,
  });
}
