import '../../../core/mock/mock_posters.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';

/// In-memory Booking fixtures — one per interesting state so every sticky
/// bar variant in §3.7 is reachable.
class MockBookingRepository implements BookingRepository {
  final Map<String, Booking> _bookings = {
    // Consumer view, IN_PROGRESS → "Mark as Complete" + "Raise a Dispute".
    'b-1': const Booking(
      id: 'b-1',
      gigTitle: 'Fix a leaking kitchen pipe',
      listingType: ListingType.gigRequest,
      amountZarMinor: 45000,
      lifecycleState: LifecycleState.inProgress,
      counterparty: MockPosters.merchantSipho,
      evidenceCount: 1,
      viewerRole: UserMode.consumer,
    ),
    // Merchant view, IN_ESCROW → "Start Work".
    'b-2': const Booking(
      id: 'b-2',
      gigTitle: 'Deep home cleaning, flats & houses',
      listingType: ListingType.gigPost,
      amountZarMinor: 35000,
      lifecycleState: LifecycleState.inEscrow,
      counterparty: MockPosters.consumerNomvula,
      evidenceCount: 0,
      viewerRole: UserMode.merchant,
    ),
    // DISPUTED → disabled "Under review by Daala" banner.
    'b-3': const Booking(
      id: 'b-3',
      gigTitle: 'Garden cleanup and lawn mowing',
      listingType: ListingType.gigRequest,
      amountZarMinor: 60000,
      lifecycleState: LifecycleState.disputed,
      counterparty: MockPosters.merchantLerato,
      evidenceCount: 2,
      viewerRole: UserMode.consumer,
    ),
    // COMPLETED → "Leave Review".
    'b-4': const Booking(
      id: 'b-4',
      gigTitle: 'Maths tutoring for Grade 10 learner',
      listingType: ListingType.gigRequest,
      amountZarMinor: 30000,
      lifecycleState: LifecycleState.completed,
      counterparty: MockPosters.merchantAyesha,
      evidenceCount: 0,
      viewerRole: UserMode.consumer,
    ),
  };

  Booking _require(String id) {
    final booking = _bookings[id];
    if (booking == null) throw BookingNotFoundException(id);
    return booking;
  }

  @override
  Future<Booking> getById(String id) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    return _require(id);
  }

  @override
  Future<Booking> markComplete(String id) async {
    await mockNetworkDelay();
    return _bookings[id] = _require(id)
        .copyWith(lifecycleState: LifecycleState.completed);
  }

  @override
  Future<Booking> startWork(String id) async {
    await mockNetworkDelay();
    return _bookings[id] = _require(id)
        .copyWith(lifecycleState: LifecycleState.inProgress);
  }

  @override
  Future<Booking> raiseDispute(String id) async {
    await mockNetworkDelay();
    return _bookings[id] = _require(id)
        .copyWith(lifecycleState: LifecycleState.disputed);
  }

  @override
  Future<Booking> addEvidence(String id) async {
    await mockNetworkDelay();
    final booking = _require(id);
    return _bookings[id] =
        booking.copyWith(evidenceCount: booking.evidenceCount + 1);
  }

  @override
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
    required bool hasPhoto,
  }) =>
      mockNetworkDelay();
}
