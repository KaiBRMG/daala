import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class GigDetailScreen extends StatelessWidget {
  const GigDetailScreen({super.key});

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
            Text('Help moving a 2-bed apartment', style: AppText.detailTitle),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: TagPill('Moving · One-time'),
            ),
            const SizedBox(height: 22),
            _posterCard(),
            const SizedBox(height: 16),
            _metaCard(),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _WhitePill('Heavy lifting'),
                _WhitePill('Own transport'),
                _WhitePill('Flexible timing'),
              ],
            ),
            const SizedBox(height: 22),
            _payoutCard(),
            const SizedBox(height: 18),
            _cta(),
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
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: AppColors.green),
              const SizedBox(width: 6),
              Text('Save',
                  style: AppText.tag.copyWith(fontSize: 13, color: AppColors.green)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _posterCard() {
    return GwCard(
      child: Row(
        children: [
          const InitialsAvatar('MT', size: 44),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Marlo T.', style: AppText.cardTitle),
              const SizedBox(height: 2),
              Text('★ 4.8 · Posted 2 hours ago', style: AppText.meta),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaCard() {
    return GwCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MetaRow('📍', 'Fitzroy VIC 3065'),
          SizedBox(height: 14),
          _MetaRow('🗓️', 'Fri 12 Jul, 9:00am'),
          SizedBox(height: 14),
          _MetaRow('👥', '1–2 helpers needed'),
        ],
      ),
    );
  }

  Widget _payoutCard() {
    return GwCard(
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                border: Border(
                    right: BorderSide(color: AppColors.dividerStrong)),
              ),
              child: _payoutCell('Estimated Payout', '\$65', AppColors.green),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _payoutCell('Duration', '~2 hrs', AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutCell(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: AppText.meta.copyWith(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink50)),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.money.copyWith(fontSize: 22, color: color)),
      ],
    );
  }

  Widget _cta() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.orangeCta,
      ),
      child: Text('Apply Now',
          style: AppText.metaStrong.copyWith(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.emoji, this.text);
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(text,
            style: AppText.metaStrong.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _WhitePill extends StatelessWidget {
  const _WhitePill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.tag),
        boxShadow: AppShadows.soft,
      ),
      child: Text(label,
          style: AppText.tag.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
