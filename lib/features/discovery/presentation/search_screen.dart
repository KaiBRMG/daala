import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/gig_category.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/daala_segmented.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/discovery_providers.dart';
import '../domain/search_filters.dart';

/// Search & Filter — full-screen (DESIGN.md §3.13): query + filter groups,
/// sticky "Show N results", recent searches.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _query = TextEditingController(
      text: ref.read(searchFiltersProvider).query);

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _update(SearchFilters filters) =>
      ref.read(searchFiltersProvider.notifier).update(filters);

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(searchFiltersProvider);
    final results = ref.watch(searchResultsProvider);
    final recent = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Search',
            style: DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(DaalaSpacing.screenH),
        children: [
          DaalaInput(
            hint: 'Search for a service or gig',
            controller: _query,
            autofocus: true,
            onChanged: (value) => _update(filters.copyWith(query: value)),
          ),
          if (filters.query.isEmpty) ...[
            const SizedBox(height: DaalaSpacing.sectionGap),
            Text('Recent searches',
                style:
                    DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
            const SizedBox(height: DaalaSpacing.s8),
            recent.maybeWhen(
              data: (searches) => Column(
                children: [
                  for (final search in searches)
                    DaalaListRow(
                      leading: const Icon(Icons.history,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                      title: search,
                      onTap: () {
                        _query.text = search;
                        _update(filters.copyWith(query: search));
                      },
                    ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Category',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s12),
          Wrap(
            spacing: DaalaSpacing.s8,
            runSpacing: DaalaSpacing.s8,
            children: [
              DaalaChip(
                label: 'All',
                selected: filters.category == null,
                onTap: () => _update(filters.copyWith(clearCategory: true)),
              ),
              for (final category in GigCategory.values)
                DaalaChip(
                  label: category.label,
                  selected: filters.category == category,
                  onTap: () =>
                      _update(filters.copyWith(category: category)),
                ),
            ],
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Distance',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: filters.maxDistanceKm,
                  min: 1,
                  max: 50,
                  onChanged: (value) =>
                      _update(filters.copyWith(maxDistanceKm: value)),
                ),
              ),
              Text('${filters.maxDistanceKm.round()} km',
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.ink500)),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s16),
          Text('Budget range',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          RangeSlider(
            values: RangeValues(filters.budgetMinZarMinor.toDouble(),
                filters.budgetMaxZarMinor.toDouble()),
            min: 0,
            max: kBudgetCeilingZarMinor.toDouble(),
            onChanged: (values) => _update(filters.copyWith(
                budgetMinZarMinor: values.start.round(),
                budgetMaxZarMinor: values.end.round())),
          ),
          Text(
            '${formatZar(filters.budgetMinZarMinor)} – '
            '${formatZar(filters.budgetMaxZarMinor)}',
            style:
                DaalaTextStyles.caption.copyWith(color: DaalaColors.ink500),
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Listing type',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s12),
          DaalaSegmented(
            expanded: true,
            segments: const ['All', 'Gig Requests', 'Gig Posts'],
            selectedIndex: switch (filters.listingType) {
              null => 0,
              ListingType.gigRequest => 1,
              ListingType.gigPost => 2,
            },
            onChanged: (i) => _update(switch (i) {
              0 => filters.copyWith(clearListingType: true),
              1 => filters.copyWith(listingType: ListingType.gigRequest),
              _ => filters.copyWith(listingType: ListingType.gigPost),
            }),
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Sort by',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s12),
          Wrap(
            spacing: DaalaSpacing.s8,
            children: [
              for (final sort in SearchSort.values)
                DaalaChip(
                  label: sort.label,
                  selected: filters.sort == sort,
                  onTap: () => _update(filters.copyWith(sort: sort)),
                ),
            ],
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          if (results.hasValue && results.requireValue.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              headline: 'No results',
              subtext: 'Try adjusting your filters or search term.',
            ),
        ],
      ),
      bottomNavigationBar: StickyBottomBar(
        child: DaalaButton(
          label: results.when(
            data: (gigs) =>
                'Show ${gigs.length} result${gigs.length == 1 ? '' : 's'}',
            loading: () => 'Searching…',
            error: (_, _) => 'Show results',
          ),
          loading: results.isLoading,
          onPressed: () => context.pop(),
        ),
      ),
    );
  }
}
