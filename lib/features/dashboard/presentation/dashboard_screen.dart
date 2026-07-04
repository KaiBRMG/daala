import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/listing_type.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/create_chooser_sheet.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/status_badge.dart';
import '../application/dashboard_providers.dart';
import '../domain/dashboard_gig.dart';

/// Dashboard / My Gigs (DESIGN.md §3.8) — unified lifecycle overview
/// across both roles.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.initialTab});

  /// `?tab=` query value (route table §2.3).
  final String? initialTab;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(dashboardTabProvider.notifier)
            .set(DashboardTab.fromQuery(widget.initialTab));
      });
    }
  }

  void _openRow(DashboardGig row) {
    switch (row.target) {
      case DashboardTarget.gigRequestDetail:
        context.push(RoutePaths.gigRequest(row.targetId));
      case DashboardTarget.gigPostDetail:
        context.push(RoutePaths.gigPost(row.targetId));
      case DashboardTarget.reviewOffers:
        context.push(RoutePaths.reviewOffers(row.targetId));
      case DashboardTarget.booking:
        context.push(RoutePaths.booking(row.targetId));
      case DashboardTarget.draftWizard:
        context.push(RoutePaths.createGigRequest);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tab = ref.watch(dashboardTabProvider);
    final rows = ref.watch(dashboardRowsProvider(tab));
    final availableZarMinor = ref.watch(walletGlanceProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DaalaSpacing.screenH,
                  DaalaSpacing.s16, DaalaSpacing.screenH, DaalaSpacing.s8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('My Gigs',
                        style: DaalaTextStyles.h1
                            .copyWith(color: DaalaColors.ink900)),
                  ),
                  DaalaChip(
                    label: formatZar(availableZarMinor),
                    onTap: () => context.push(RoutePaths.wallet),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: DaalaSizes.touchTarget,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: DaalaSpacing.screenH,
                    vertical: DaalaSpacing.s4),
                itemCount: DashboardTab.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: DaalaSpacing.s8),
                itemBuilder: (context, i) {
                  final value = DashboardTab.values[i];
                  return DaalaChip(
                    label: value.label,
                    selected: value == tab,
                    onTap: () =>
                        ref.read(dashboardTabProvider.notifier).set(value),
                  );
                },
              ),
            ),
            const SizedBox(height: DaalaSpacing.s8),
            Expanded(
              child: rows.when(
                loading: () => Shimmer(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, _) => const ListRowSkeleton(),
                  ),
                ),
                error: (_, _) => ErrorState(
                    onRetry: () =>
                        ref.invalidate(dashboardRowsProvider(tab))),
                data: (list) => list.isEmpty
                    ? _emptyFor(tab)
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, i) =>
                            _DashboardGigRow(
                                row: list[i],
                                onTap: () => _openRow(list[i])),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFor(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.active:
        return EmptyState(
          icon: Icons.assignment_outlined,
          headline: 'No active gigs',
          subtext:
              'Post a Gig Request or offer your services to get started.',
          action: DaalaButton(
            label: 'Post a Gig',
            expand: false,
            onPressed: () => showCreateChooserSheet(context),
          ),
        );
      case DashboardTab.offers:
        return const EmptyState(
          icon: Icons.local_offer_outlined,
          headline: 'No offers yet',
          subtext: 'Offers on your Gig Requests will appear here.',
        );
      case DashboardTab.inEscrow:
        return const EmptyState(
          icon: Icons.shield_outlined,
          headline: 'Nothing in Escrow',
          subtext: 'Funds are held here while gigs are underway.',
        );
      case DashboardTab.completed:
        return const EmptyState(
          icon: Icons.check_circle_outline,
          headline: 'No completed gigs yet',
          subtext: 'Finished gigs and released payments show here.',
        );
      case DashboardTab.drafts:
        return const EmptyState(
          icon: Icons.edit_note_outlined,
          headline: 'No drafts',
          subtext: 'Save a gig wizard midway and pick it up here.',
        );
    }
  }
}

class _DashboardGigRow extends StatelessWidget {
  const _DashboardGigRow({required this.row, required this.onTap});

  final DashboardGig row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (row.counterpartyName != null) 'with ${row.counterpartyName}',
      formatRelative(row.updatedAt),
    ];
    return DaalaListRow(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          LeadingCircleIcon(
              icon: row.listingType == ListingType.gigRequest
                  ? Icons.checklist_outlined
                  : Icons.storefront_outlined),
          if (row.unreadFlag)
            Positioned(
              top: 0,
              right: 0,
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
      title: row.title,
      subtitle: subtitleParts.join(' · '),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StatusBadge(state: row.statusEnum),
          if (row.amountZarMinor > 0) ...[
            const SizedBox(height: DaalaSpacing.s4),
            Text(formatZar(row.amountZarMinor),
                style: DaalaTextStyles.moneyMd
                    .copyWith(color: DaalaColors.ink900)),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
