import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_feed_store.dart';
import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../data/mock_gig_request_repository.dart';
import '../domain/gig_request.dart';
import '../domain/gig_request_repository.dart';
import '../domain/offer.dart';

final gigRequestRepositoryProvider = Provider<GigRequestRepository>(
    (ref) => MockGigRequestRepository(ref.watch(mockFeedStoreProvider)));

final gigRequestProvider = FutureProvider.autoDispose
    .family<GigRequest, String>((ref, id) async {
  return ref.watch(gigRequestRepositoryProvider).getById(id);
});

/// How the current viewer relates to a Gig Request — owner sees Review
/// Offers, a Merchant sees Make an Offer (DESIGN.md §3.2).
ViewerRelationship viewerRelationshipFor(
    MockSession session, GigRequest request) {
  if (request.poster.id == MockSession.userId) {
    return ViewerRelationship.owner;
  }
  return session.mode == UserMode.merchant
      ? ViewerRelationship.merchant
      : ViewerRelationship.other;
}

enum OfferSort { price, rating }

class OfferSortNotifier extends Notifier<OfferSort> {
  @override
  OfferSort build() => OfferSort.price;

  void set(OfferSort sort) => state = sort;
}

final offerSortProvider =
    NotifierProvider<OfferSortNotifier, OfferSort>(OfferSortNotifier.new);

final offersProvider = FutureProvider.autoDispose
    .family<List<Offer>, String>((ref, gigRequestId) async {
  final offers = await ref
      .watch(gigRequestRepositoryProvider)
      .offersFor(gigRequestId);
  final sorted = [...offers];
  switch (ref.watch(offerSortProvider)) {
    case OfferSort.price:
      sorted.sort((a, b) => a.amountZarMinor.compareTo(b.amountZarMinor));
    case OfferSort.rating:
      sorted.sort(
          (a, b) => b.merchant.ratingAvg.compareTo(a.merchant.ratingAvg));
  }
  return sorted;
});

/// Mock platform fee (DESIGN.md §3.5): Merchant receives 85%.
const int platformFeePercent = 15;

int netAfterFeeZarMinor(int amountZarMinor) =>
    amountZarMinor * (100 - platformFeePercent) ~/ 100;

class OfferActions {
  OfferActions(this._ref);

  final Ref _ref;

  Future<void> submitOffer({
    required String gigRequestId,
    required int amountZarMinor,
    required String message,
  }) async {
    await _ref.read(gigRequestRepositoryProvider).submitOffer(
          gigRequestId: gigRequestId,
          amountZarMinor: amountZarMinor,
          message: message,
        );
    _ref.invalidate(gigRequestProvider(gigRequestId));
    _ref.invalidate(offersProvider(gigRequestId));
  }

  Future<String> acceptOffer({
    required String gigRequestId,
    required String offerId,
  }) {
    return _ref.read(gigRequestRepositoryProvider).acceptOffer(
        gigRequestId: gigRequestId, offerId: offerId);
  }
}

final offerActionsProvider = Provider<OfferActions>(OfferActions.new);
