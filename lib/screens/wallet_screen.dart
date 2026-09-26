import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../money.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
          children: [
            _header(context),
            const SizedBox(height: 22),
            _overline('Balance'),
            const SizedBox(height: 8),
            _balanceCard(),
            const SizedBox(height: 22),
            _overline('Recent Activity'),
            const SizedBox(height: 8),
            _txnCard(),
            const SizedBox(height: 14),
            _addPaymentCard(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RoundIconButton(
          icon: Icons.arrow_back_ios_new,
          iconSize: 16,
          onTap: () => context.pop(),
        ),
        Text('My Wallet', style: AppText.appBarTitle),
        const RoundIconButton(icon: Icons.add, iconSize: 18),
      ],
    );
  }

  Widget _overline(String text) => Text(text.toUpperCase(),
      style: AppText.label.copyWith(color: AppColors.inkMuted, letterSpacing: 0.3));

  Widget _balanceCard() {
    return GwCard(
      color: AppColors.cream,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO(phase7): balance and escrow come from TradeSafe. A new
          // account truthfully holds nothing until then.
          Text('Available Balance',
              style: AppText.body.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.greenMuted)),
          const SizedBox(height: 6),
          Text(formatZar(0, cents: true),
              style: AppText.money.copyWith(color: AppColors.green)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text('Withdraw to Bank',
                style: AppText.tag.copyWith(fontSize: 13, color: AppColors.green)),
          ),
        ],
      ),
    );
  }

  Widget _txnCard() {
    return const EmptyState(
      'No money in or out yet',
      body: 'Payments for gigs you do, and gigs you hire for, show up here.',
    );
  }

  Widget _addPaymentCard() {
    return GwCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, size: 20, color: AppColors.cream),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add payment method', style: AppText.rowTitle),
                const SizedBox(height: 2),
                Text('Bank account or card', style: AppText.meta),
              ],
            ),
          ),
          const Icon(Icons.add, size: 18, color: AppColors.cream),
        ],
      ),
    );
  }
}
