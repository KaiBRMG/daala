import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/models/gig_summary.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_segmented.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/gig_card.dart';
import '../../../core/widgets/map_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/discovery_providers.dart';

/// Home / Discovery — feed ⇄ map toggle, search, categories
/// (DESIGN.md §3.1).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.initialView});

  /// `view=feed|map` query param (route table §2.3).
  final String? initialView;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialView == 'map') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(homeViewProvider.notifier).set(HomeView.map);
      });
    }
  }

  void _openGig(GigSummary gig) {
    context.push(gig.listingType == ListingType.gigRequest
        ? RoutePaths.gigRequest(gig.id)
        : RoutePaths.gigPost(gig.id));
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(homeViewProvider);
    final feed = ref.watch(feedProvider);
    final filtersActive = ref.watch(searchFiltersProvider).isActive;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: DaalaColors.bgPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: DaalaSpacing.screenH,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Molo, ${MockSession.firstName} 👋',
                      style: DaalaTextStyles.title
                          .copyWith(color: DaalaColors.ink900),
                    ),
                  ),
                  _NotificationBell(
                      onTap: () =>
                          context.push(RoutePaths.notifications)),
                  const SizedBox(width: DaalaSpacing.s8),
                  const DaalaAvatar(
                      name: MockSession.displayName,
                      size: DaalaSizes.avatarSm),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(
                    DaalaSizes.searchFieldHeight + DaalaSpacing.s12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(DaalaSpacing.screenH,
                      0, DaalaSpacing.screenH, DaalaSpacing.s12),
                  child: _SearchField(
                      onTap: () => context.push(RoutePaths.search)),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedBarDelegate(
                height: DaalaSizes.touchTarget + DaalaSpacing.s8,
                child: Container(
                  color: DaalaColors.bgPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: DaalaSpacing.screenH,
                      vertical: DaalaSpacing.s4),
                  child: Row(
                    children: [
                      DaalaSegmented(
                        segments: const ['Feed', 'Map'],
                        selectedIndex: view == HomeView.feed ? 0 : 1,
                        onChanged: (i) => ref
                            .read(homeViewProvider.notifier)
                            .set(i == 0 ? HomeView.feed : HomeView.map),
                      ),
                      const Spacer(),
                      DaalaChip(
                        label: 'Filters',
                        showDot: filtersActive,
                        onTap: () => context.push(RoutePaths.search),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: DaalaSizes.touchTarget,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: DaalaSpacing.screenH,
                      vertical: DaalaSpacing.s4),
                  itemCount: GigCategory.values.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: DaalaSpacing.s8),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return DaalaChip(
                        label: 'All',
                        selected: selectedCategory == null,
                        onTap: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .set(null),
                      );
                    }
                    final category = GigCategory.values[i - 1];
                    return DaalaChip(
                      label: category.label,
                      selected: selectedCategory == category,
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .set(category),
                    );
                  },
                ),
              ),
            ),
            if (view == HomeView.feed)
              ..._feedSlivers(feed)
            else
              _mapSliver(feed),
          ],
        ),
      ),
    );
  }

  List<Widget> _feedSlivers(AsyncValue<List<GigSummary>> feed) {
    return [
      feed.when(
        loading: () => SliverPadding(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          sliver: SliverList.separated(
            itemCount: 6,
            separatorBuilder: (_, _) =>
                const SizedBox(height: DaalaSpacing.s12),
            itemBuilder: (_, _) =>
                const Shimmer(child: GigCardSkeleton()),
          ),
        ),
        error: (_, _) => SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(onRetry: () => ref.invalidate(feedProvider)),
        ),
        data: (gigs) {
          if (gigs.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off,
                headline: 'No gigs nearby yet',
                subtext: 'Try widening your filters or check back soon.',
                action: DaalaChip(
                  label: 'Clear filters',
                  onTap: () {
                    ref.read(searchFiltersProvider.notifier).clear();
                    ref.read(selectedCategoryProvider.notifier).set(null);
                  },
                ),
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.all(DaalaSpacing.screenH),
            sliver: SliverList.separated(
              itemCount: gigs.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: DaalaSpacing.s12),
              itemBuilder: (context, i) => GigCard(
                  gig: gigs[i], onTap: () => _openGig(gigs[i])),
            ),
          );
        },
      ),
    ];
  }

  Widget _mapSliver(AsyncValue<List<GigSummary>> feed) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(DaalaSpacing.screenH),
        child: feed.when(
          loading: () => const Shimmer(
              child: ShimmerBox(height: double.infinity,
                  radius: DaalaRadius.rLg)),
          error: (_, _) =>
              ErrorState(onRetry: () => ref.invalidate(feedProvider)),
          data: (gigs) => gigs.isEmpty
              ? const _MapEmpty()
              : MapPlaceholder(
                  height: null,
                  pinCount: gigs.length,
                  caption:
                      'Map preview — live map arrives in a later phase'),
        ),
      ),
    );
  }
}

class _MapEmpty extends StatelessWidget {
  const _MapEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.place_outlined,
              size: DaalaSizes.emptyStateIcon, color: DaalaColors.ink300),
          const SizedBox(height: DaalaSpacing.s12),
          Text('No gigs to show on the map.',
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink500)),
        ],
      ),
    );
  }
}

/// Tap-through search affordance — routes to /search, not focusable inline.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DaalaColors.bgSecondary,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: DaalaSizes.searchFieldHeight,
          child: Row(
            children: [
              const SizedBox(width: DaalaSpacing.s16),
              const Icon(Icons.search,
                  color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              const SizedBox(width: DaalaSpacing.s8),
              Text('Search for a service or gig',
                  style: DaalaTextStyles.body
                      .copyWith(color: DaalaColors.ink300)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: DaalaSizes.touchTarget,
        height: DaalaSizes.touchTarget,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_outlined,
                color: DaalaColors.ink900, size: DaalaSizes.iconLg),
            Positioned(
              top: DaalaSpacing.s12,
              right: DaalaSpacing.s12,
              child: Container(
                width: DaalaSpacing.s8,
                height: DaalaSpacing.s8,
                decoration: const BoxDecoration(
                  color: DaalaColors.accentOrange500,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinnedBarDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedBarDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset,
          bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant _PinnedBarDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
