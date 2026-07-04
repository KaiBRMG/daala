import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_booking_repository.dart';
import '../domain/booking.dart';
import '../domain/booking_repository.dart';

final bookingRepositoryProvider =
    Provider<BookingRepository>((ref) => MockBookingRepository());

final bookingProvider =
    FutureProvider.autoDispose.family<Booking, String>((ref, id) async {
  return ref.watch(bookingRepositoryProvider).getById(id);
});

/// Sticky-bar actions — mock state transitions update immediately
/// (DESIGN.md §3.7).
class BookingActions {
  BookingActions(this._ref);

  final Ref _ref;

  BookingRepository get _repository =>
      _ref.read(bookingRepositoryProvider);

  Future<void> markComplete(String id) async {
    await _repository.markComplete(id);
    _ref.invalidate(bookingProvider(id));
  }

  Future<void> startWork(String id) async {
    await _repository.startWork(id);
    _ref.invalidate(bookingProvider(id));
  }

  Future<void> raiseDispute(String id) async {
    await _repository.raiseDispute(id);
    _ref.invalidate(bookingProvider(id));
  }

  Future<void> addEvidence(String id) async {
    await _repository.addEvidence(id);
    _ref.invalidate(bookingProvider(id));
  }

  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
    required bool hasPhoto,
  }) {
    return _repository.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
        hasPhoto: hasPhoto);
  }
}

final bookingActionsProvider = Provider<BookingActions>(BookingActions.new);
