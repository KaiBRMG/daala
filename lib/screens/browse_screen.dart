import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  static const _chips = ['All', 'Moving', 'Design', 'Delivery', 'Garden'];
  static const _gigs = [
    ('Assemble flatpack shelving', '1.2km · Moving', '\$65'),
    ('Logo design for cafe', 'Remote · Design', '\$300'),
    ('Grocery delivery run', '0.8km · Delivery', '\$28'),
    ('Weekly hedge trim', '2.4km · Garden', '\$45'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          padding: const EdgeInsets.only(top: 18, bottom: 120),
          children: [
            Text('Browse Gigs', style: AppText.screenTitleLg),
            const SizedBox(height: 16),
            _searchRow(),
            const SizedBox(height: 14),
            _chipRow(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('142 gigs nearby',
                    style: AppText.label.copyWith(color: AppColors.ink50)),
                Text('Sort: Closest',
                    style: AppText.label.copyWith(color: AppColors.green)),
              ],
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _gigs.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _gigRow(context, _gigs[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.ink40),
                const SizedBox(width: 8),
                Text('Search gigs near you',
                    style: AppText.metaStrong.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink35)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const RoundIconButton(
          icon: Icons.tune,
          bg: AppColors.green,
          iconColor: AppColors.white,
          iconSize: 17,
        ),
      ],
    );
  }

  Widget _chipRow() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.green : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              boxShadow: active ? null : AppShadows.soft,
            ),
            child: Text(
              _chips[i],
              style: AppText.tag.copyWith(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? AppColors.white : AppColors.ink,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _gigRow(BuildContext context, (String, String, String) g) {
    final (title, meta, price) = g;
    return GwCard(
      onTap: () => context.push('/gig'),
      child: Row(
        children: [
          const PhotoPlaceholder(width: 48, height: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.rowTitle),
                const SizedBox(height: 2),
                Text(meta, style: AppText.meta),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(price, style: AppText.price),
        ],
      ),
    );
  }
}
