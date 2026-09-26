import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const _chips = ['All', 'Moving', 'Design', 'Delivery', 'Garden'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ListView(
            padding: const EdgeInsets.only(top: 6, bottom: 120),
            children: [
              _header(context),
              const SizedBox(height: 18),
              Text('Search', style: AppText.screenTitleLg),
              const SizedBox(height: 16),
              _searchRow(),
              const SizedBox(height: 14),
              _chipRow(),
              const SizedBox(height: 20),
              // TODO(phase4): query results replace this once gigs exist.
              const EmptyState(
                'No gigs near you yet',
                body: 'New Tasks and Listings near you will show up here.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RoundIconButton(
        icon: Icons.arrow_back_ios_new,
        iconSize: 16,
        onTap: () => context.pop(),
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
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 16, color: AppColors.inkFaint),
                const SizedBox(width: 8),
                Text('Search gigs near you',
                    style: AppText.metaStrong.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkMuted)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        const RoundIconButton(
          icon: Icons.tune,
          bg: AppColors.cream,
          iconColor: AppColors.green,
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
              color: active ? AppColors.cream : AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Text(
              _chips[i],
              style: AppText.tag.copyWith(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: active ? AppColors.green : AppColors.ink,
              ),
            ),
          );
        },
      ),
    );
  }
}
