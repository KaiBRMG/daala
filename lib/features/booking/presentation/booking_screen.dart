import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/booking_providers.dart';
import '../domain/booking.dart';

/// Booking / Escrow Status (DESIGN.md §3.7) — escrow panel, lifecycle
/// timeline, evidence, and the correct next action for each party.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  bool _actionBusy = false;

  Future<void> _run(Future<void> Function() action,
      {String? successMessage}) async {
    setState(() => _actionBusy = true);
    try {
      await action();
      if (mounted && successMessage != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmDispute() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Raise a Dispute?',
                  textAlign: TextAlign.center,
                  style: DaalaTextStyles.h3
                      .copyWith(color: DaalaColors.ink900)),
              const SizedBox(height: DaalaSpacing.s8),
              Text(
                'Escrowed funds will be frozen while Daala reviews the '
                'Dispute.',
                textAlign: TextAlign.center,
                style:
                    DaalaTextStyles.body.copyWith(color: DaalaColors.ink500),
              ),
              const SizedBox(height: DaalaSpacing.s24),
              DaalaButton(
                label: 'Raise a Dispute',
                variant: DaalaButtonVariant.destructive,
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
    if (confirmed == true) {
      await _run(
          () => ref.read(bookingActionsProvider).raiseDispute(widget.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Booking',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: booking.when(
        loading: () => const _BookingSkeleton(),
        error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(bookingProvider(widget.id))),
        data: (data) => _body(data),
      ),
      bottomNavigationBar: booking.maybeWhen(
        data: (data) => _stickyBar(data),
        orElse: () => null,
      ),
    );
  }

  Widget _body(Booking booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DaalaSpacing.screenH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DaalaCard(
            child: Row(
              children: [
                DaalaAvatar(
                    name: booking.counterparty.displayName,
                    size: DaalaSizes.avatarMd),
                const SizedBox(width: DaalaSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.gigTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DaalaTextStyles.title
                              .copyWith(color: DaalaColors.ink900)),
                      Text('with ${booking.counterparty.displayName}',
                          style: DaalaTextStyles.caption
                              .copyWith(color: DaalaColors.ink500)),
                    ],
                  ),
                ),
                const SizedBox(width: DaalaSpacing.s8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatZar(booking.amountZarMinor),
                        style: DaalaTextStyles.moneyMd
                            .copyWith(color: DaalaColors.ink900)),
                    const SizedBox(height: DaalaSpacing.s4),
                    StatusBadge(state: booking.lifecycleState),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          _EscrowStatusPanel(booking: booking),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Timeline',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s16),
          _LifecycleTimeline(steps: booking.timeline),
          const SizedBox(height: DaalaSpacing.sectionGap),
          Text('Completion evidence',
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s12),
          Wrap(
            spacing: DaalaSpacing.s8,
            runSpacing: DaalaSpacing.s8,
            children: [
              for (var i = 0; i < booking.evidenceCount; i++)
                const MediaPlaceholder(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
              InkWell(
                borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                onTap: () =>
                    context.push(RoutePaths.evidence(booking.id)),
                child: Container(
                  width: DaalaSizes.galleryTile,
                  height: DaalaSizes.galleryTile,
                  decoration: BoxDecoration(
                    color: DaalaColors.bgSecondary,
                    borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                    border: Border.all(
                        color: DaalaColors.borderDefault,
                        width: DaalaSizes.borderWidth),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                      const SizedBox(height: DaalaSpacing.s4),
                      Text('Add photo',
                          style: DaalaTextStyles.overline
                              .copyWith(color: DaalaColors.ink500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DaalaSpacing.sectionGap),
          DaalaCard(
            padding: EdgeInsets.zero,
            child: DaalaListRow(
              leading:
                  const LeadingCircleIcon(icon: Icons.chat_bubble_outline),
              title: 'Messages',
              subtitle: 'Chat with ${booking.counterparty.displayName}',
              trailing: const Icon(Icons.chevron_right,
                  color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              showDivider: false,
              onTap: () => context.push(
                  RoutePaths.chatThread('t-${booking.counterparty.id}')),
            ),
          ),
          const SizedBox(height: DaalaSpacing.s24),
        ],
      ),
    );
  }

  Widget? _stickyBar(Booking booking) {
    if (booking.lifecycleState == LifecycleState.disputed) {
      return StickyBottomBar(
        child: Container(
          padding: const EdgeInsets.all(DaalaSpacing.s12),
          decoration: BoxDecoration(
            color: DaalaColors.statusDisputeBg,
            borderRadius: BorderRadius.circular(DaalaRadius.rMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gavel_outlined,
                  size: DaalaSizes.iconSm,
                  color: DaalaColors.statusDispute),
              const SizedBox(width: DaalaSpacing.s8),
              Text('Under review by Daala',
                  style: DaalaTextStyles.label
                      .copyWith(color: DaalaColors.statusDispute)),
            ],
          ),
        ),
      );
    }

    if (booking.viewerRole == UserMode.consumer &&
        booking.lifecycleState == LifecycleState.inProgress) {
      return StickyBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DaalaButton(
              label: 'Mark as Complete',
              loading: _actionBusy,
              onPressed: () => _run(
                  () => ref
                      .read(bookingActionsProvider)
                      .markComplete(widget.id),
                  successMessage: 'Funds released from Escrow'),
            ),
            const SizedBox(height: DaalaSpacing.s4),
            DaalaButton(
              label: 'Raise a Dispute',
              variant: DaalaButtonVariant.destructiveText,
              onPressed: _actionBusy ? null : _confirmDispute,
            ),
          ],
        ),
      );
    }

    if (booking.viewerRole == UserMode.merchant &&
        booking.lifecycleState == LifecycleState.inEscrow) {
      return StickyBottomBar(
        child: DaalaButton(
          label: 'Start Work',
          loading: _actionBusy,
          onPressed: () => _run(
              () => ref.read(bookingActionsProvider).startWork(widget.id)),
        ),
      );
    }

    if (booking.viewerRole == UserMode.merchant &&
        booking.lifecycleState == LifecycleState.inProgress) {
      return StickyBottomBar(
        child: DaalaButton(
          label: 'Mark work done',
          loading: _actionBusy,
          // TODO(spec): Merchant "work done" flow unspecified — the
          // Consumer confirms completion to release Escrow.
          onPressed: () => _run(() async {},
              successMessage:
                  'The Consumer has been asked to confirm completion'),
        ),
      );
    }

    if (booking.lifecycleState == LifecycleState.completed) {
      return StickyBottomBar(
        child: DaalaButton(
          label: 'Leave Review',
          onPressed: () =>
              context.push(RoutePaths.leaveReview(booking.id)),
        ),
      );
    }

    return null;
  }
}

/// The emotional anchor — calm tinted panel with shield icon and a big
/// reassuring amount (ANZ secure/trustworthy tone).
class _EscrowStatusPanel extends StatelessWidget {
  const _EscrowStatusPanel({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final released =
        booking.lifecycleState == LifecycleState.completed ||
            booking.lifecycleState == LifecycleState.resolved;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DaalaSpacing.s20),
      decoration: BoxDecoration(
        color: released
            ? DaalaColors.statusSuccessBg
            : DaalaColors.statusEscrowBg,
        borderRadius: BorderRadius.circular(DaalaRadius.rXl),
      ),
      child: Row(
        children: [
          Icon(released ? Icons.verified_outlined : Icons.shield_outlined,
              size: DaalaSizes.emptyStateIcon,
              color: released
                  ? DaalaColors.statusSuccess
                  : DaalaColors.statusEscrow),
          const SizedBox(width: DaalaSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatZar(booking.amountZarMinor),
                    style: DaalaTextStyles.moneyLg
                        .copyWith(color: DaalaColors.ink900)),
                Text(
                  released
                      ? 'released from Escrow'
                      : 'held securely in Escrow',
                  style: DaalaTextStyles.body.copyWith(
                      color: released
                          ? DaalaColors.statusSuccess
                          : DaalaColors.statusEscrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical stepper — filled/outlined dots with a 2 px connector.
class _LifecycleTimeline extends StatelessWidget {
  const _LifecycleTimeline({required this.steps});

  final List<BookingTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    _dot(steps[i]),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          width: DaalaSpacing.s2,
                          color: steps[i].done || steps[i].current
                              ? DaalaColors.brandGreen900
                              : DaalaColors.borderDefault,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: DaalaSpacing.s12),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: DaalaSpacing.s24),
                    child: Text(
                      steps[i].label,
                      style: DaalaTextStyles.body.copyWith(
                        color: steps[i].current
                            ? DaalaColors.brandGreen900
                            : steps[i].done
                                ? DaalaColors.ink900
                                : DaalaColors.ink300,
                        fontWeight: steps[i].current
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _dot(BookingTimelineStep step) {
    if (step.done) {
      return Container(
        width: DaalaSpacing.s20,
        height: DaalaSpacing.s20,
        decoration: const BoxDecoration(
            color: DaalaColors.brandGreen900, shape: BoxShape.circle),
        child: const Icon(Icons.check,
            size: DaalaSpacing.s12, color: DaalaColors.onBrand),
      );
    }
    return Container(
      width: DaalaSpacing.s20,
      height: DaalaSpacing.s20,
      decoration: BoxDecoration(
        color: step.current
            ? DaalaColors.brandGreen900
            : DaalaColors.bgPrimary,
        shape: BoxShape.circle,
        border: Border.all(
          color: step.current
              ? DaalaColors.brandGreen900
              : DaalaColors.ink300,
          width: DaalaSizes.borderWidthFocus,
        ),
      ),
    );
  }
}

class _BookingSkeleton extends StatelessWidget {
  const _BookingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(DaalaSpacing.screenH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(height: 80, radius: DaalaRadius.rLg),
            SizedBox(height: DaalaSpacing.sectionGap),
            ShimmerBox(height: 96, radius: DaalaRadius.rXl),
            SizedBox(height: DaalaSpacing.sectionGap),
            ShimmerBox(width: 120, height: DaalaSpacing.s16),
            SizedBox(height: DaalaSpacing.s16),
            ShimmerBox(height: DaalaSpacing.s16),
            SizedBox(height: DaalaSpacing.s12),
            ShimmerBox(height: DaalaSpacing.s16),
            SizedBox(height: DaalaSpacing.s12),
            ShimmerBox(height: DaalaSpacing.s16),
            SizedBox(height: DaalaSpacing.s12),
            ShimmerBox(height: DaalaSpacing.s16),
          ],
        ),
      ),
    );
  }
}
