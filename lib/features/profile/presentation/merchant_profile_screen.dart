import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_segmented.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/profile_providers.dart';
import '../domain/merchant_profile.dart';

/// Public Merchant Profile (DESIGN.md §3.10) — the trust/conversion
/// surface: stats, portfolio, reviews, verification.
class MerchantProfileScreen extends ConsumerWidget {
  const MerchantProfileScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(merchantProfileProvider(id));
    final tab = ref.watch(merchantProfileTabProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Profile',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: profile.when(
        loading: () => const _ProfileSkeleton(),
        error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(merchantProfileProvider(id))),
        data: (data) => _body(context, ref, data, tab),
      ),
      bottomNavigationBar: profile.maybeWhen(
        data: (data) => StickyBottomBar(
          child: Row(
            children: [
              Expanded(
                child: DaalaButton(
                  label: 'Message',
                  variant: DaalaButtonVariant.secondary,
                  onPressed: () => context
                      .push(RoutePaths.chatThread('t-${data.summary.id}')),
                ),
              ),
              const SizedBox(width: DaalaSpacing.s12),
              Expanded(
                child: DaalaButton(
                  label:
                      "See ${data.summary.displayName.split(' ').first}'s "
                      'Gigs',
                  // TODO(spec): filtered per-merchant listing unspecified —
                  // routes to the discovery feed.
                  onPressed: () => context.go(RoutePaths.home),
                ),
              ),
            ],
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref,
      MerchantProfile profile, MerchantProfileTab tab) {
    final summary = profile.summary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DaalaSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DaalaAvatar(
                  name: summary.displayName, size: DaalaSizes.avatarLg),
              const SizedBox(width: DaalaSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(summary.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DaalaTextStyles.h3
                                  .copyWith(color: DaalaColors.ink900)),
                        ),
                        if (summary.isVerified) ...[
                          const SizedBox(width: DaalaSpacing.s4),
                          const Icon(Icons.verified,
                              size: DaalaSizes.iconSm,
                              color: DaalaColors.brandGreen700),
                        ],
                      ],
                    ),
                    if (profile.categories.isNotEmpty) ...[
                      const SizedBox(height: DaalaSpacing.s8),
                      Wrap(
                        spacing: DaalaSpacing.s8,
                        runSpacing: DaalaSpacing.s4,
                        children: [
                          for (final category in profile.categories)
                            DaalaChip(label: category.label),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s24),
          DaalaCard(
            child: Row(
              children: [
                _Stat(
                    value:
                        '⭐ ${summary.ratingAvg.toStringAsFixed(1)}',
                    label: '${summary.reviewCount} reviews'),
                _statDivider(),
                _Stat(
                    value: '${summary.jobsCompleted ?? 0}',
                    label: 'Gigs completed'),
                _statDivider(),
                _Stat(
                    value: '${summary.completionRate ?? 0}%',
                    label: 'Completion'),
              ],
            ),
          ),
          const SizedBox(height: DaalaSpacing.s12),
          Text(
            'Responds in ${summary.responseTimeLabel ?? '—'} · Member '
            'since ${summary.memberSince ?? '—'} · '
            '${profile.serviceArea}',
            style:
                DaalaTextStyles.caption.copyWith(color: DaalaColors.ink500),
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          DaalaSegmented(
            expanded: true,
            segments: const ['Portfolio', 'Reviews', 'About'],
            selectedIndex: tab.index,
            onChanged: (i) => ref
                .read(merchantProfileTabProvider.notifier)
                .set(MerchantProfileTab.values[i]),
          ),
          const SizedBox(height: DaalaSpacing.s16),
          switch (tab) {
            MerchantProfileTab.portfolio => _portfolio(profile),
            MerchantProfileTab.reviews => _reviews(profile),
            MerchantProfileTab.about => _about(profile),
          },
          const SizedBox(height: DaalaSpacing.s24),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(
        width: DaalaSizes.borderWidth,
        height: DaalaSpacing.s32,
        color: DaalaColors.borderSubtle,
      );

  Widget _portfolio(MerchantProfile profile) {
    if (profile.portfolioCount == 0) {
      return _inlineEmpty('No portfolio photos yet.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: DaalaSpacing.s8,
        crossAxisSpacing: DaalaSpacing.s8,
      ),
      itemCount: profile.portfolioCount,
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

  Widget _reviews(MerchantProfile profile) {
    if (profile.reviews.isEmpty) {
      return _inlineEmpty('No reviews yet.');
    }
    return Column(
      children: [
        for (final review in profile.reviews) ...[
          DaalaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DaalaAvatar(
                        name: review.author, size: DaalaSizes.avatarSm),
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
                    style: DaalaTextStyles.body
                        .copyWith(color: DaalaColors.ink700)),
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
          ),
          const SizedBox(height: DaalaSpacing.s12),
        ],
      ],
    );
  }

  Widget _about(MerchantProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(profile.bio,
            style: DaalaTextStyles.body.copyWith(color: DaalaColors.ink700)),
        const SizedBox(height: DaalaSpacing.s24),
        if (profile.categories.isNotEmpty) ...[
          Text('SKILLS & CATEGORIES',
              style: DaalaTextStyles.overline
                  .copyWith(color: DaalaColors.ink500)),
          const SizedBox(height: DaalaSpacing.s8),
          Wrap(
            spacing: DaalaSpacing.s8,
            runSpacing: DaalaSpacing.s8,
            children: [
              for (final category in profile.categories)
                DaalaChip(label: category.label),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s24),
        ],
        Text('VERIFICATION',
            style: DaalaTextStyles.overline
                .copyWith(color: DaalaColors.ink500)),
        const SizedBox(height: DaalaSpacing.s8),
        Row(
          children: [
            Icon(
                profile.summary.isVerified
                    ? Icons.verified
                    : Icons.shield_outlined,
                size: DaalaSizes.iconSm,
                color: profile.summary.isVerified
                    ? DaalaColors.brandGreen700
                    : DaalaColors.ink300),
            const SizedBox(width: DaalaSpacing.s8),
            Text(
              profile.summary.isVerified
                  ? 'Identity verified with Daala'
                  : 'Identity not yet verified',
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink700),
            ),
          ],
        ),
      ],
    );
  }

  Widget _inlineEmpty(String copy) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DaalaSpacing.s24),
      decoration: BoxDecoration(
        color: DaalaColors.bgSecondary,
        borderRadius: BorderRadius.circular(DaalaRadius.rMd),
      ),
      child: Text(copy,
          textAlign: TextAlign.center,
          style:
              DaalaTextStyles.caption.copyWith(color: DaalaColors.ink500)),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style:
                  DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s2),
          Text(label,
              textAlign: TextAlign.center,
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500)),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(DaalaSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(
                    width: DaalaSizes.avatarLg,
                    height: DaalaSizes.avatarLg,
                    radius: DaalaRadius.rPill),
                SizedBox(width: DaalaSpacing.s16),
                Expanded(child: ShimmerBox(height: DaalaSpacing.s24)),
              ],
            ),
            SizedBox(height: DaalaSpacing.s24),
            ShimmerBox(height: 80, radius: DaalaRadius.rLg),
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
    );
  }
}
