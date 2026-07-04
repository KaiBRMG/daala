import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/map_placeholder.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/gig_request_providers.dart';
import '../domain/gig_request.dart';

/// Gig Request Detail (DESIGN.md §3.2).
class GigRequestDetailScreen extends ConsumerWidget {
  const GigRequestDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(gigRequestProvider(id));
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Gig Request',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: DaalaColors.ink900, size: DaalaSizes.iconLg),
            // TODO(spec): share action deferred — no behaviour specified.
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert,
                color: DaalaColors.ink900, size: DaalaSizes.iconLg),
            // TODO(spec): overflow menu contents unspecified.
            onPressed: () {},
          ),
        ],
      ),
      body: request.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => error is GigRequestNotFoundException
            ? ErrorState(
                title: 'This gig is no longer available',
                detail: 'It may have been completed or removed.',
                retryLabel: 'Back to Home',
                onRetry: () => context.go(RoutePaths.home),
              )
            : ErrorState(
                onRetry: () => ref.invalidate(gigRequestProvider(id))),
        data: (gig) => _DetailBody(gig: gig),
      ),
      bottomNavigationBar: request.maybeWhen(
        data: (gig) {
          final relationship = viewerRelationshipFor(session, gig);
          switch (relationship) {
            case ViewerRelationship.owner:
              return StickyBottomBar(
                child: DaalaButton(
                  label: 'Review Offers (${gig.offerCount})',
                  onPressed: () =>
                      context.push(RoutePaths.reviewOffers(gig.id)),
                ),
              );
            case ViewerRelationship.merchant:
              return StickyBottomBar(
                child: gig.viewerHasSubmittedOffer
                    ? const DaalaButton(
                        label: 'Offer submitted', onPressed: null)
                    : DaalaButton(
                        label: 'Make an Offer',
                        onPressed: () =>
                            context.push(RoutePaths.makeOffer(gig.id)),
                      ),
              );
            case ViewerRelationship.other:
              // TODO(spec): no CTA specified for a Consumer viewing
              // another Consumer's Gig Request.
              return null;
          }
        },
        orElse: () => null,
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.gig});

  final GigRequest gig;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DaalaSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block — ANZ "hero number" treatment for the budget.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(gig.title,
                    style: DaalaTextStyles.h2
                        .copyWith(color: DaalaColors.ink900)),
              ),
              const SizedBox(width: DaalaSpacing.s8),
              StatusBadge(state: gig.statusEnum),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s16),
          Text('BUDGET',
              style: DaalaTextStyles.overline
                  .copyWith(color: DaalaColors.ink500)),
          Text(formatZar(gig.budgetZarMinor),
              style: DaalaTextStyles.moneyLg
                  .copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.sectionGap),
          DaalaCard(
            onTap: () => context.push(RoutePaths.merchant(gig.poster.id)),
            child: Row(
              children: [
                DaalaAvatar(
                    name: gig.poster.displayName,
                    size: DaalaSizes.avatarMd),
                const SizedBox(width: DaalaSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(gig.poster.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DaalaTextStyles.title.copyWith(
                                    color: DaalaColors.ink900)),
                          ),
                          if (gig.poster.isVerified) ...[
                            const SizedBox(width: DaalaSpacing.s4),
                            const Icon(Icons.verified,
                                size: DaalaSizes.iconSm,
                                color: DaalaColors.brandGreen700),
                          ],
                        ],
                      ),
                      Text(
                        '⭐ ${gig.poster.ratingAvg.toStringAsFixed(1)} '
                        '(${gig.poster.reviewCount}) · Member since '
                        '${gig.poster.memberSince ?? '—'}',
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              ],
            ),
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          _MetaGrid(gig: gig),
          const SizedBox(height: DaalaSpacing.sectionGap),
          const MapPlaceholder(caption: 'Approximate location'),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Details',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s8),
          Text(gig.description,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink700)),
          if (gig.photoCount > 0) ...[
            const SizedBox(height: DaalaSpacing.sectionGap),
            Text('What needs doing',
                style:
                    DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
            const SizedBox(height: DaalaSpacing.s12),
            SizedBox(
              height: DaalaSizes.galleryTile,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gig.photoCount,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: DaalaSpacing.s8),
                itemBuilder: (_, _) => const MediaPlaceholder(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
              ),
            ),
          ],
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Offers (${gig.offerCount})',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s8),
          Text(
            gig.offerCount == 0
                ? 'No Offers yet.'
                : '${gig.offerCount} Merchant'
                    '${gig.offerCount == 1 ? ' has' : 's have'} made an '
                    'Offer on this Gig Request.',
            style:
                DaalaTextStyles.caption.copyWith(color: DaalaColors.ink500),
          ),
          const SizedBox(height: DaalaSpacing.s24),
        ],
      ),
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.gig});

  final GigRequest gig;

  @override
  Widget build(BuildContext context) {
    final entries = [
      (Icons.place_outlined, 'Suburb / area', gig.suburb),
      (Icons.schedule, 'When needed', gig.whenNeededLabel),
      (Icons.calendar_today_outlined, 'Posted',
          formatRelative(gig.createdAt)),
      (Icons.sell_outlined, 'Category', gig.category.label),
    ];
    return Column(
      children: [
        for (var row = 0; row < entries.length; row += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: DaalaSpacing.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _MetaCell(entry: entries[row])),
                if (row + 1 < entries.length)
                  Expanded(child: _MetaCell(entry: entries[row + 1])),
              ],
            ),
          ),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.entry});

  final (IconData, String, String) entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(entry.$1, size: DaalaSizes.iconSm, color: DaalaColors.ink500),
        const SizedBox(width: DaalaSpacing.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.$2,
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.ink500)),
              Text(entry.$3,
                  style: DaalaTextStyles.body
                      .copyWith(color: DaalaColors.ink900)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(DaalaSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: DaalaSpacing.s24),
            SizedBox(height: DaalaSpacing.s16),
            ShimmerBox(width: 140, height: DaalaSpacing.s32),
            SizedBox(height: DaalaSpacing.sectionGap),
            ShimmerBox(height: 72, radius: DaalaRadius.rLg),
            SizedBox(height: DaalaSpacing.sectionGap),
            ShimmerBox(
                height: DaalaSizes.mapBlockHeight,
                radius: DaalaRadius.rLg),
            SizedBox(height: DaalaSpacing.sectionGap),
            ShimmerBox(height: DaalaSpacing.s12),
            SizedBox(height: DaalaSpacing.s8),
            ShimmerBox(height: DaalaSpacing.s12),
            SizedBox(height: DaalaSpacing.s8),
            ShimmerBox(width: 200, height: DaalaSpacing.s12),
            SizedBox(height: DaalaSpacing.sectionGap),
            Row(
              children: [
                ShimmerBox(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
                SizedBox(width: DaalaSpacing.s8),
                ShimmerBox(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
