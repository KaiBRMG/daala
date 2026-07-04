import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/review.dart';
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
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/gig_post_providers.dart';
import '../domain/gig_post.dart';

/// Gig Post Detail (DESIGN.md §3.3).
class GigPostDetailScreen extends ConsumerStatefulWidget {
  const GigPostDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<GigPostDetailScreen> createState() =>
      _GigPostDetailScreenState();
}

class _GigPostDetailScreenState
    extends ConsumerState<GigPostDetailScreen> {
  int _carouselPage = 0;

  Future<void> _confirmBook(GigPost post) async {
    final booked = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_outlined,
                  size: DaalaSizes.emptyStateIcon,
                  color: DaalaColors.statusEscrow),
              const SizedBox(height: DaalaSpacing.s16),
              Text(
                'Book ${post.merchant.displayName} from '
                '${formatZar(post.priceFromZarMinor)}?',
                textAlign: TextAlign.center,
                style:
                    DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900),
              ),
              const SizedBox(height: DaalaSpacing.s8),
              Text(
                'Funds will be held in Escrow until you mark the gig '
                'complete.',
                textAlign: TextAlign.center,
                style:
                    DaalaTextStyles.body.copyWith(color: DaalaColors.ink500),
              ),
              const SizedBox(height: DaalaSpacing.s24),
              DaalaButton(
                label: 'Confirm Booking',
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: DaalaSpacing.s8),
              DaalaButton(
                label: 'Cancel',
                variant: DaalaButtonVariant.tertiary,
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (booked != true || !mounted) return;
    final bookingId =
        await ref.read(gigPostRepositoryProvider).book(post.id);
    if (!mounted) return;
    context.push(RoutePaths.booking(bookingId));
  }

  @override
  Widget build(BuildContext context) {
    final post = ref.watch(gigPostProvider(widget.id));
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Gig Post',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: post.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => error is GigPostNotFoundException
            ? ErrorState(
                title: 'This gig is no longer available',
                detail: 'It may have been paused or removed.',
                retryLabel: 'Back to Home',
                onRetry: () => context.go(RoutePaths.home),
              )
            : ErrorState(
                onRetry: () =>
                    ref.invalidate(gigPostProvider(widget.id))),
        data: (gigPost) => _body(gigPost),
      ),
      bottomNavigationBar: post.maybeWhen(
        data: (gigPost) {
          final relationship =
              gigPostViewerRelationship(session, gigPost);
          if (relationship == ViewerRelationship.owner) {
            return const StickyBottomBar(
              // Phase 1: editing routes to a disabled stub.
              child: DaalaButton(label: 'Edit Gig Post', onPressed: null),
            );
          }
          return StickyBottomBar(
            child: Row(
              children: [
                Expanded(
                  child: DaalaButton(
                    label: 'Enquire',
                    variant: DaalaButtonVariant.secondary,
                    onPressed: () => context.push(
                        RoutePaths.chatThread('t-${gigPost.merchant.id}')),
                  ),
                ),
                const SizedBox(width: DaalaSpacing.s12),
                Expanded(
                  child: DaalaButton(
                      label: 'Book',
                      onPressed: () => _confirmBook(gigPost)),
                ),
              ],
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _body(GigPost post) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.mediaCount > 0)
            _MediaCarousel(
              count: post.mediaCount,
              page: _carouselPage,
              onPageChanged: (i) => setState(() => _carouselPage = i),
            )
          else
            // Cream hero when the post has no media.
            Container(
              height: DaalaSizes.mapBlockHeight,
              width: double.infinity,
              color: DaalaColors.surfaceCream,
              child: const Icon(Icons.storefront_outlined,
                  size: DaalaSizes.emptyStateIcon,
                  color: DaalaColors.brandGreen900),
            ),
          Padding(
            padding: const EdgeInsets.all(DaalaSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: DaalaTextStyles.h2
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: DaalaSpacing.s4,
                      horizontal: DaalaSpacing.s8),
                  decoration: BoxDecoration(
                    color: DaalaColors.brandGreen50,
                    borderRadius:
                        BorderRadius.circular(DaalaRadius.rPill),
                  ),
                  child: Text(post.category.label.toUpperCase(),
                      style: DaalaTextStyles.overline
                          .copyWith(color: DaalaColors.brandGreen900)),
                ),
                const SizedBox(height: DaalaSpacing.s16),
                Text('FROM',
                    style: DaalaTextStyles.overline
                        .copyWith(color: DaalaColors.ink500)),
                Text(formatZar(post.priceFromZarMinor),
                    style: DaalaTextStyles.moneyLg
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.sectionGap),
                DaalaCard(
                  onTap: () =>
                      context.push(RoutePaths.merchant(post.merchant.id)),
                  child: Row(
                    children: [
                      DaalaAvatar(
                          name: post.merchant.displayName,
                          size: DaalaSizes.avatarMd),
                      const SizedBox(width: DaalaSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(post.merchant.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: DaalaTextStyles.title
                                          .copyWith(
                                              color:
                                                  DaalaColors.ink900)),
                                ),
                                if (post.merchant.isVerified) ...[
                                  const SizedBox(width: DaalaSpacing.s4),
                                  const Icon(Icons.verified,
                                      size: DaalaSizes.iconSm,
                                      color: DaalaColors.brandGreen700),
                                ],
                              ],
                            ),
                            Text(
                              '⭐ ${post.merchant.ratingAvg.toStringAsFixed(1)} '
                              '(${post.merchant.reviewCount}) · '
                              '${post.merchant.jobsCompleted ?? 0} gigs '
                              'completed',
                              style: DaalaTextStyles.caption
                                  .copyWith(color: DaalaColors.ink500),
                            ),
                            Text(
                              'Responds in '
                              '${post.merchant.responseTimeLabel ?? '—'}',
                              style: DaalaTextStyles.caption
                                  .copyWith(color: DaalaColors.ink500),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                    ],
                  ),
                ),
                const SizedBox(height: DaalaSpacing.sectionGap),
                Text('About this service',
                    style: DaalaTextStyles.h3
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.s8),
                Text(post.description,
                    style: DaalaTextStyles.body
                        .copyWith(color: DaalaColors.ink700)),
                const SizedBox(height: DaalaSpacing.sectionGap),
                Text('Portfolio',
                    style: DaalaTextStyles.h3
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.s12),
                if (post.portfolioCount == 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DaalaSpacing.s24),
                    decoration: BoxDecoration(
                      color: DaalaColors.bgSecondary,
                      borderRadius:
                          BorderRadius.circular(DaalaRadius.rMd),
                    ),
                    child: Text('No photos yet',
                        textAlign: TextAlign.center,
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500)),
                  )
                else
                  _PortfolioGrid(count: post.portfolioCount),
                const SizedBox(height: DaalaSpacing.sectionGap),
                Text('Service area',
                    style: DaalaTextStyles.h3
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.s12),
                MapPlaceholder(caption: post.serviceAreaLabel),
                const SizedBox(height: DaalaSpacing.s8),
                Text(
                  'Serves within ~${post.serviceRadiusKm} km of '
                  '${post.serviceAreaLabel}.',
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.ink500),
                ),
                const SizedBox(height: DaalaSpacing.sectionGap),
                Text('Reviews',
                    style: DaalaTextStyles.h3
                        .copyWith(color: DaalaColors.ink900)),
                const SizedBox(height: DaalaSpacing.s12),
                if (post.reviews.isEmpty)
                  Text('No reviews yet.',
                      style: DaalaTextStyles.caption
                          .copyWith(color: DaalaColors.ink500))
                else ...[
                  for (final review in post.reviews.take(2)) ...[
                    _ReviewCard(review: review),
                    const SizedBox(height: DaalaSpacing.s12),
                  ],
                  DaalaButton(
                    label: 'See all ${post.reviews.length} review'
                        '${post.reviews.length == 1 ? '' : 's'}',
                    variant: DaalaButtonVariant.tertiary,
                    onPressed: () => context
                        .push(RoutePaths.merchant(post.merchant.id)),
                  ),
                ],
                const SizedBox(height: DaalaSpacing.s24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCarousel extends StatelessWidget {
  const _MediaCarousel({
    required this.count,
    required this.page,
    required this.onPageChanged,
  });

  final int count;
  final int page;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: count,
            onPageChanged: onPageChanged,
            itemBuilder: (_, _) => const MediaPlaceholder(radius: 0),
          ),
          Positioned(
            bottom: DaalaSpacing.s12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < count; i++)
                  Container(
                    width: DaalaSpacing.s8,
                    height: DaalaSpacing.s8,
                    margin: const EdgeInsets.symmetric(
                        horizontal: DaalaSpacing.s2),
                    decoration: BoxDecoration(
                      color: i == page
                          ? DaalaColors.brandGreen900
                          : DaalaColors.bgPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  const _PortfolioGrid({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DaalaSpacing.s8,
        crossAxisSpacing: DaalaSpacing.s8,
      ),
      itemCount: count,
      itemBuilder: (context, i) => InkWell(
        borderRadius: BorderRadius.circular(DaalaRadius.rMd),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1,
              child: MediaPlaceholder(radius: DaalaRadius.rLg),
            ),
          ),
        ),
        child: const MediaPlaceholder(),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return DaalaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DaalaAvatar(name: review.author, size: DaalaSizes.avatarSm),
              const SizedBox(width: DaalaSpacing.s8),
              Expanded(
                child: Text(review.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DaalaTextStyles.label
                        .copyWith(color: DaalaColors.ink900)),
              ),
              StarRating(rating: review.rating),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s8),
          Text(review.comment,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink700)),
          const SizedBox(height: DaalaSpacing.s4),
          Text(formatShortDate(review.date),
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500)),
          if (review.hasPhoto) ...[
            const SizedBox(height: DaalaSpacing.s8),
            const MediaPlaceholder(
                width: DaalaSizes.galleryTile,
                height: DaalaSizes.galleryTile),
          ],
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
              aspectRatio: 16 / 9,
              child: ShimmerBox(height: double.infinity, radius: 0)),
          Padding(
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
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 120)),
                    SizedBox(width: DaalaSpacing.s8),
                    Expanded(child: ShimmerBox(height: 120)),
                  ],
                ),
                SizedBox(height: DaalaSpacing.s8),
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 120)),
                    SizedBox(width: DaalaSpacing.s8),
                    Expanded(child: ShimmerBox(height: 120)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
