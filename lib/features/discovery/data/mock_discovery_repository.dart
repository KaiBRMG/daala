import '../../../core/mock/mock_feed_store.dart';
import '../../../core/models/gig_summary.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/discovery_repository.dart';
import '../domain/search_filters.dart';

const List<String> _recentSearches = [
  'plumber',
  'garden service',
  'maths tutor',
];

class MockDiscoveryRepository implements DiscoveryRepository {
  MockDiscoveryRepository(this._store);

  final MockFeedStore _store;

  @override
  Future<List<GigSummary>> search(SearchFilters filters) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();

    final query = filters.query.trim().toLowerCase();
    final results = _store.gigs.where((gig) {
      if (query.isNotEmpty && !gig.title.toLowerCase().contains(query)) {
        return false;
      }
      if (filters.category != null && gig.category != filters.category) {
        return false;
      }
      if (filters.listingType != null &&
          gig.listingType != filters.listingType) {
        return false;
      }
      if (gig.distanceKm > filters.maxDistanceKm) return false;
      final amount = gig.listingType == ListingType.gigRequest
          ? (gig.budgetZarMinor ?? 0)
          : (gig.priceFromZarMinor ?? 0);
      if (amount < filters.budgetMinZarMinor ||
          amount > filters.budgetMaxZarMinor) {
        return false;
      }
      return true;
    }).toList();

    switch (filters.sort) {
      case SearchSort.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SearchSort.price:
        results.sort((a, b) =>
            (a.budgetZarMinor ?? a.priceFromZarMinor ?? 0).compareTo(
                b.budgetZarMinor ?? b.priceFromZarMinor ?? 0));
      case SearchSort.rating:
        results.sort(
            (a, b) => b.poster.ratingAvg.compareTo(a.poster.ratingAvg));
    }

    return DebugFlags.maybeEmpty(results);
  }

  @override
  Future<List<String>> recentSearches() async {
    await mockNetworkDelay();
    return _recentSearches;
  }
}
