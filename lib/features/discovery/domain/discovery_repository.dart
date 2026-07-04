import '../../../core/models/gig_summary.dart';
import 'search_filters.dart';

/// Discovery feed + search. Mock in Phase 1; Firestore queries later.
abstract class DiscoveryRepository {
  /// Mixed feed of Gig Requests and Gig Posts matching [filters].
  Future<List<GigSummary>> search(SearchFilters filters);

  Future<List<String>> recentSearches();
}
