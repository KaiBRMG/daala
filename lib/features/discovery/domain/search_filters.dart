import '../../../core/models/gig_category.dart';
import '../../../core/models/listing_type.dart';

enum SearchSort {
  newest('Newest'),
  price('Price'),
  rating('Rating');

  const SearchSort(this.label);

  final String label;
}

const double kDefaultMaxDistanceKm = 25;
const int kBudgetCeilingZarMinor = 500000;

/// Search & Filter query state (DESIGN.md §3.13 Search & Filter).
class SearchFilters {
  const SearchFilters({
    this.query = '',
    this.category,
    this.maxDistanceKm = kDefaultMaxDistanceKm,
    this.budgetMinZarMinor = 0,
    this.budgetMaxZarMinor = kBudgetCeilingZarMinor,
    this.listingType,
    this.sort = SearchSort.newest,
  });

  final String query;
  final GigCategory? category;
  final double maxDistanceKm;
  final int budgetMinZarMinor;
  final int budgetMaxZarMinor;

  /// Null = both Gig Requests and Gig Posts.
  final ListingType? listingType;
  final SearchSort sort;

  bool get isActive =>
      query.isNotEmpty ||
      category != null ||
      listingType != null ||
      maxDistanceKm != kDefaultMaxDistanceKm ||
      budgetMinZarMinor != 0 ||
      budgetMaxZarMinor != kBudgetCeilingZarMinor ||
      sort != SearchSort.newest;

  SearchFilters copyWith({
    String? query,
    GigCategory? category,
    bool clearCategory = false,
    double? maxDistanceKm,
    int? budgetMinZarMinor,
    int? budgetMaxZarMinor,
    ListingType? listingType,
    bool clearListingType = false,
    SearchSort? sort,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      budgetMinZarMinor: budgetMinZarMinor ?? this.budgetMinZarMinor,
      budgetMaxZarMinor: budgetMaxZarMinor ?? this.budgetMaxZarMinor,
      listingType:
          clearListingType ? null : listingType ?? this.listingType,
      sort: sort ?? this.sort,
    );
  }
}
