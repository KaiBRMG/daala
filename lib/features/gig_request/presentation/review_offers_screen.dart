import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/daala_segmented.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/gig_request_providers.dart';
import '../domain/offer.dart';

/// Review Offers (DESIGN.md §3.6): the owning Consumer compares Offers and
/// accepts one → Booking + Escrow.
class ReviewOffersScreen extends ConsumerWidget {
  const ReviewOffersScreen({super.key, required this.gigRequestId});

  final String gigRequestId;

  Future<void> _confirmAccept(
      BuildContext context, WidgetRef ref, Offer offer) async {
    final accepted = await showModalBottomSheet<bool>(
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
                'Accept ${offer.merchant.displayName}’s Offer of '
                '${formatZar(offer.amountZarMinor)}?',
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
                label: 'Accept Offer',
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
    if (accepted != true || !context.mounted) return;

    final bookingId = await ref.read(offerActionsProvider).acceptOffer(
        gigRequestId: gigRequestId, offerId: offer.id);
    if (!context.mounted) return;
    context.push(RoutePaths.booking(bookingId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers = ref.watch(offersProvider(gigRequestId));
    final sort = ref.watch(offerSortProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text(
          offers.maybeWhen(
              data: (list) => 'Offers (${list.length})',
              orElse: () => 'Offers'),
          style: DaalaTextStyles.title.copyWith(color: DaalaColors.ink900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DaalaSpacing.s16),
            child: DaalaSegmented(
              segments: const ['Price', 'Rating'],
              selectedIndex: sort == OfferSort.price ? 0 : 1,
              onChanged: (i) => ref
                  .read(offerSortProvider.notifier)
                  .set(i == 0 ? OfferSort.price : OfferSort.rating),
            ),
          ),
        ],
      ),
      body: offers.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          itemCount: 4,
          separatorBuilder: (_, _) =>
              const SizedBox(height: DaalaSpacing.s12),
          itemBuilder: (_, _) => const Shimmer(
            child: DaalaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerCircle(size: DaalaSizes.avatarMd),
                      SizedBox(width: DaalaSpacing.s12),
                      Expanded(child: ShimmerBox(height: DaalaSpacing.s16)),
                      SizedBox(width: DaalaSpacing.s12),
                      ShimmerBox(width: 64, height: DaalaSpacing.s20),
                    ],
                  ),
                  SizedBox(height: DaalaSpacing.s12),
                  ShimmerBox(height: DaalaSpacing.s12),
                  SizedBox(height: DaalaSpacing.s8),
                  ShimmerBox(width: 180, height: DaalaSpacing.s12),
                ],
              ),
            ),
          ),
        ),
        error: (_, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(offersProvider(gigRequestId))),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.schedule,
                headline: 'No offers yet',
                subtext: 'Merchants nearby will start bidding soon.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(DaalaSpacing.screenH),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: DaalaSpacing.s12),
                itemBuilder: (context, i) => _OfferCard(
                  offer: list[i],
                  onMessage: () => context.push(
                      RoutePaths.chatThread('t-${list[i].merchant.id}')),
                  onAccept: () =>
                      _confirmAccept(context, ref, list[i]),
                ),
              ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.onMessage,
    required this.onAccept,
  });

  final Offer offer;
  final VoidCallback onMessage;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final merchant = offer.merchant;
    return DaalaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DaalaAvatar(
                  name: merchant.displayName, size: DaalaSizes.avatarMd),
              const SizedBox(width: DaalaSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(merchant.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DaalaTextStyles.title
                                  .copyWith(color: DaalaColors.ink900)),
                        ),
                        if (merchant.isVerified) ...[
                          const SizedBox(width: DaalaSpacing.s4),
                          const Icon(Icons.verified,
                              size: DaalaSizes.iconSm,
                              color: DaalaColors.brandGreen700),
                        ],
                      ],
                    ),
                    Text(
                      '⭐ ${merchant.ratingAvg.toStringAsFixed(1)} '
                      '(${merchant.reviewCount}) · '
                      '${merchant.jobsCompleted ?? 0} gigs · '
                      '${merchant.completionRate ?? 0}% completion',
                      style: DaalaTextStyles.caption
                          .copyWith(color: DaalaColors.ink500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DaalaSpacing.s8),
              Text(formatZar(offer.amountZarMinor),
                  style: DaalaTextStyles.moneyMd
                      .copyWith(color: DaalaColors.ink900)),
            ],
          ),
          const SizedBox(height: DaalaSpacing.s12),
          Text(offer.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink700)),
          const SizedBox(height: DaalaSpacing.s16),
          Row(
            children: [
              Expanded(
                child: DaalaButton(
                  label: 'Message',
                  variant: DaalaButtonVariant.secondary,
                  onPressed: onMessage,
                ),
              ),
              const SizedBox(width: DaalaSpacing.s12),
              Expanded(
                child:
                    DaalaButton(label: 'Accept Offer', onPressed: onAccept),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
