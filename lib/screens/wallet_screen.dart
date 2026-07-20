import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const _txns = [
    ('Grocery delivery run', '+\$28.00', true),
    ('Logo design deposit', '+\$150.00', true),
    ('Platform fee', '-\$4.20', false),
    ('Withdrawal to bank', '-\$200.00', false),
  ];

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
            _overline('Recent Gigs'),
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
      style: AppText.label.copyWith(color: AppColors.ink50, letterSpacing: 0.3));

  Widget _balanceCard() {
    return GwCard(
      color: AppColors.green,
      shadow: AppShadows.card,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance',
              style: AppText.body.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white70)),
          const SizedBox(height: 6),
          Text('\$1,978.85',
              style: AppText.money.copyWith(color: AppColors.white)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text('Withdraw to Bank',
                style: AppText.tag.copyWith(fontSize: 13, color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _txnCard() {
    return GwCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        children: [
          for (var i = 0; i < _txns.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: i == _txns.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_txns[i].$1,
                      style: AppText.metaStrong
                          .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(_txns[i].$2,
                      style: AppText.tag.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _txns[i].$3 ? AppColors.green : AppColors.ink60,
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _addPaymentCard() {
    return GwCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text('💳', style: TextStyle(fontSize: 18)),
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
          const Icon(Icons.add, size: 18, color: AppColors.green),
        ],
      ),
    );
  }
}
