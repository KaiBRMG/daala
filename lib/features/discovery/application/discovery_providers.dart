import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_feed_store.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/models/gig_summary.dart';
import '../data/mock_discovery_repository.dart';
import '../domain/discovery_repository.dart';
import '../domain/search_filters.dart';

enum HomeView { feed, map }

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
    (ref) => MockDiscoveryRepository(ref.watch(mockFeedStoreProvider)));

class HomeViewNotifier extends Notifier<HomeView> {
  @override
  HomeView build() => HomeView.feed;

  void set(HomeView view) => state = view;
}

final homeViewProvider =
    NotifierProvider<HomeViewNotifier, HomeView>(HomeViewNotifier.new);

/// Quick category chip on Home ("All" = null).
class SelectedCategoryNotifier extends Notifier<GigCategory?> {
  @override
  GigCategory? build() => null;

  void set(GigCategory? category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, GigCategory?>(
        SelectedCategoryNotifier.new);

/// Full-screen Search & Filter state; the Home "Filters" chip dot reflects
/// [SearchFilters.isActive].
class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => const SearchFilters();

  void update(SearchFilters filters) => state = filters;

  void clear() => state = const SearchFilters();
}

final searchFiltersProvider =
    NotifierProvider<SearchFiltersNotifier, SearchFilters>(
        SearchFiltersNotifier.new);

/// Home feed — search filters merged with the quick category chip.
final feedProvider =
    FutureProvider.autoDispose<List<GigSummary>>((ref) async {
  final repository = ref.watch(discoveryRepositoryProvider);
  final filters = ref.watch(searchFiltersProvider);
  final chipCategory = ref.watch(selectedCategoryProvider);
  final effective = chipCategory == null
      ? filters
      : filters.copyWith(category: chipCategory);
  return repository.search(effective);
});

/// Live result set for the Search & Filter screen's "Show N results" CTA.
final searchResultsProvider =
    FutureProvider.autoDispose<List<GigSummary>>((ref) async {
  final repository = ref.watch(discoveryRepositoryProvider);
  return repository.search(ref.watch(searchFiltersProvider));
});

final recentSearchesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  return ref.watch(discoveryRepositoryProvider).recentSearches();
});
