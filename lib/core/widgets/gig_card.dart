import 'package:flutter/material.dart';

import '../models/gig_summary.dart';
import '../models/listing_type.dart';
import '../theme/tokens.dart';
import '../utils/format_zar.dart';
import 'daala_avatar.dart';
import 'daala_card.dart';
import 'media_placeholder.dart';
import 'shimmer.dart';
import 'status_badge.dart';

/// The core repeating feed unit (DESIGN.md §3.1): flat bordered card with
/// type tag, status badge, title, meta row, optional thumbnail, poster
/// mini and price.
class GigCard extends StatelessWidget {
  const GigCard({super.key, required this.gig, this.onTap});

  final GigSummary gig;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = gig.listingType == ListingType.gigRequest
        ? formatZar(gig.budgetZarMinor ?? 0)
        : 'from ${formatZar(gig.priceFromZarMinor ?? 0)}';

    return DaalaCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ListingTypeTag(type: gig.listingType),
              const Spacer(),
              StatusBadge(state: gig.statusEnum),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gig.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: DaalaTextStyles.title
                          .copyWith(color: DaalaColors.ink900),
                    ),
                    const SizedBox(height: DaalaSpacing.s8),
                    Wrap(
                      spacing: DaalaSpacing.s12,
                      runSpacing: DaalaSpacing.s4,
                      children: [
                        _Meta(icon: Icons.place_outlined, text: gig.suburb),
                        _Meta(
                            icon: Icons.schedule,
                            text: gig.timingLabel),
                        _Meta(
                            icon: Icons.near_me_outlined,
                            text:
                                '${gig.distanceKm.toStringAsFixed(1)} km away'),
                      ],
                    ),
                  ],
                ),
              ),
              if (gig.hasThumbnail) ...[
                const SizedBox(width: DaalaSpacing.s12),
                const MediaPlaceholder(
                    width: DaalaSizes.cardThumb,
                    height: DaalaSizes.cardThumb),
              ],
            ],
          ),
          const SizedBox(height: DaalaSpacing.s12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    DaalaAvatar(
                        name: gig.poster.displayName,
                        size: DaalaSizes.avatarXs),
                    const SizedBox(width: DaalaSpacing.s8),
                    Flexible(
                      child: Text(
                        gig.poster.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500),
                      ),
                    ),
                    const SizedBox(width: DaalaSpacing.s4),
                    const Icon(Icons.star,
                        size: DaalaSizes.iconSm,
                        color: DaalaColors.statusPending),
                    Text(
                      gig.poster.ratingAvg.toStringAsFixed(1),
                      style: DaalaTextStyles.caption
                          .copyWith(color: DaalaColors.ink500),
                    ),
                    if (gig.offerCount > 0) ...[
                      const SizedBox(width: DaalaSpacing.s8),
                      _OffersBadge(count: gig.offerCount),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DaalaSpacing.s8),
              Text(price,
                  style: DaalaTextStyles.moneyMd
                      .copyWith(color: DaalaColors.ink900)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "REQUEST" (tinted green) / "SERVICE" (tinted cream) overline pill.
class ListingTypeTag extends StatelessWidget {
  const ListingTypeTag({super.key, required this.type});

  final ListingType type;

  @override
  Widget build(BuildContext context) {
    final isRequest = type == ListingType.gigRequest;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: DaalaSpacing.s4, horizontal: DaalaSpacing.s8),
      decoration: BoxDecoration(
        color: isRequest
            ? DaalaColors.brandGreen50
            : DaalaColors.surfaceCream,
        borderRadius: BorderRadius.circular(DaalaRadius.rPill),
      ),
      child: Text(
        type.tagLabel,
        style: DaalaTextStyles.overline.copyWith(
            color: isRequest
                ? DaalaColors.brandGreen900
                : DaalaColors.ink900),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: DaalaSizes.iconSm, color: DaalaColors.ink500),
        const SizedBox(width: DaalaSpacing.s4),
        Text(text,
            style:
                DaalaTextStyles.caption.copyWith(color: DaalaColors.ink500)),
      ],
    );
  }
}

class _OffersBadge extends StatelessWidget {
  const _OffersBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DaalaSpacing.s8, vertical: DaalaSpacing.s2),
      decoration: BoxDecoration(
        color: DaalaColors.accentOrange500,
        borderRadius: BorderRadius.circular(DaalaRadius.rPill),
      ),
      child: Text(
        '$count offer${count == 1 ? '' : 's'}',
        style:
            DaalaTextStyles.overline.copyWith(color: DaalaColors.onBrand),
      ),
    );
  }
}

/// Shimmer skeleton matching the GigCard silhouette (title bar, two meta
/// lines, footer row).
class GigCardSkeleton extends StatelessWidget {
  const GigCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const DaalaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 72, height: DaalaSpacing.s16),
              Spacer(),
              ShimmerBox(width: 56, height: DaalaSpacing.s16),
            ],
          ),
          SizedBox(height: DaalaSpacing.s12),
          ShimmerBox(height: DaalaSpacing.s20),
          SizedBox(height: DaalaSpacing.s8),
          ShimmerBox(width: 180, height: DaalaSpacing.s12),
          SizedBox(height: DaalaSpacing.s12),
          Row(
            children: [
              ShimmerBox(
                  width: DaalaSizes.avatarXs,
                  height: DaalaSizes.avatarXs,
                  radius: DaalaRadius.rPill),
              SizedBox(width: DaalaSpacing.s8),
              ShimmerBox(width: 96, height: DaalaSpacing.s12),
              Spacer(),
              ShimmerBox(width: 64, height: DaalaSpacing.s20),
            ],
          ),
        ],
      ),
    );
  }
}
