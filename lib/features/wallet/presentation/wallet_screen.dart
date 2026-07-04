import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_wallet_store.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/wallet_providers.dart';
import '../domain/wallet_repository.dart';

/// Wallet (DESIGN.md §3.11) — money at rest and in motion, reinforcing
/// Escrow trust. Mock in Phase 1.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Wallet',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: wallet.when(
        loading: () => const _WalletSkeleton(),
        error: (_, _) =>
            ErrorState(onRetry: () => ref.invalidate(walletProvider)),
        data: (data) => _body(data),
      ),
    );
  }

  Widget _body(WalletData wallet) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(DaalaSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BalanceHero — cream card with the ANZ big-figure look.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DaalaSpacing.s24),
                  decoration: BoxDecoration(
                    color: DaalaColors.surfaceCream,
                    borderRadius: BorderRadius.circular(DaalaRadius.rXl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AVAILABLE',
                          style: DaalaTextStyles.overline
                              .copyWith(color: DaalaColors.ink500)),
                      Text(formatZar(wallet.availableZarMinor),
                          style: DaalaTextStyles.moneyLg
                              .copyWith(color: DaalaColors.ink900)),
                      const SizedBox(height: DaalaSpacing.s12),
                      Row(
                        children: [
                          const Icon(Icons.shield_outlined,
                              size: DaalaSizes.iconSm,
                              color: DaalaColors.statusEscrow),
                          const SizedBox(width: DaalaSpacing.s8),
                          Text(
                            'In Escrow: '
                            '${formatZar(wallet.inEscrowZarMinor)}',
                            style: DaalaTextStyles.label.copyWith(
                                color: DaalaColors.statusEscrow),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DaalaSpacing.s16),
                const Row(
                  children: [
                    // Disabled stubs until TradeSafe (Phase 7).
                    Expanded(
                        child: DaalaButton(
                            label: 'Withdraw', onPressed: null)),
                    SizedBox(width: DaalaSpacing.s12),
                    Expanded(
                      child: DaalaButton(
                          label: 'Top up',
                          variant: DaalaButtonVariant.secondary,
                          onPressed: null),
                    ),
                  ],
                ),
                const SizedBox(height: DaalaSpacing.sectionGap),
                Text('Transactions',
                    style: DaalaTextStyles.h3
                        .copyWith(color: DaalaColors.ink900)),
              ],
            ),
          ),
        ),
        if (wallet.transactions.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              headline: 'No transactions yet',
              subtext:
                  'Payments in and out of your Wallet will appear here.',
            ),
          )
        else
          SliverList.builder(
            itemCount: wallet.transactions.length,
            itemBuilder: (context, i) =>
                _TxnRow(txn: wallet.transactions[i]),
          ),
      ],
    );
  }
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.txn});

  final WalletTxn txn;

  (IconData, Color) get _iconFor {
    switch (txn.type) {
      case TxnType.credit:
        return (Icons.south_west, DaalaColors.statusSuccess);
      case TxnType.debit:
        return (Icons.north_east, DaalaColors.ink700);
      case TxnType.escrowHold:
        return (Icons.shield_outlined, DaalaColors.statusEscrow);
      case TxnType.escrowRelease:
        return (Icons.lock_open_outlined, DaalaColors.statusSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconFor;
    final incoming = txn.amountZarMinor > 0;
    return DaalaListRow(
      leading: LeadingCircleIcon(icon: icon, color: color),
      title: txn.label,
      subtitle: [
        if (txn.counterparty != null) txn.counterparty!,
        formatShortDate(txn.date),
      ].join(' · '),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${incoming ? '+' : ''}${formatZar(txn.amountZarMinor)}',
            style: DaalaTextStyles.moneyMd.copyWith(
                color: incoming
                    ? DaalaColors.statusSuccess
                    : DaalaColors.ink900),
          ),
          Text(txn.status,
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500)),
        ],
      ),
    );
  }
}

class _WalletSkeleton extends StatelessWidget {
  const _WalletSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(DaalaSpacing.screenH),
        child: Column(
          children: [
            const ShimmerBox(height: 140, radius: DaalaRadius.rXl),
            const SizedBox(height: DaalaSpacing.sectionGap),
            for (var i = 0; i < 5; i++) ...[
              const ListRowSkeleton(),
              const SizedBox(height: DaalaSpacing.s8),
            ],
          ],
        ),
      ),
    );
  }
}
