import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../money.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class MyGigsScreen extends StatefulWidget {
  const MyGigsScreen({super.key});

  @override
  State<MyGigsScreen> createState() => _MyGigsScreenState();
}

class _MyGigsScreenState extends State<MyGigsScreen> {
  int _tab = 0;
  static const _tabs = ['Upcoming', 'Applied', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          padding: const EdgeInsets.only(top: 18, bottom: 120),
          children: [
            Text('My Gigs', style: AppText.screenTitleLg),
            const SizedBox(height: 18),
            _segmented(),
            const SizedBox(height: 22),
            _sectionLabel('Tomorrow'),
            const SizedBox(height: 10),
            _bookingCard(
              title: 'Garden cleanup',
              status: 'Confirmed',
              statusBg: AppColors.greenTint,
              statusFg: AppColors.green,
              avatarInitials: 'MT',
              sub: 'Marlo T. · 9:00am',
              price: '${formatZar(6500)} fixed',
            ),
            const SizedBox(height: 16),
            _sectionLabel('This Week'),
            const SizedBox(height: 10),
            _bookingCard(
              title: 'Logo design for cafe',
              status: 'In progress',
              statusBg: AppColors.trackFill,
              statusFg: AppColors.ink55,
              sub: 'Fri 12 Jul · Remote',
              price: '${formatZar(30000)} fixed',
            ),
            const SizedBox(height: 12),
            _bookingCard(
              title: 'Grocery delivery run',
              status: 'Confirmed',
              statusBg: AppColors.greenTint,
              statusFg: AppColors.green,
              sub: 'Sat 13 Jul · 0.8km',
              price: '${formatZar(2800)} fixed',
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.trackFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: _tab == i
                      ? BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppShadows.soft,
                        )
                      : null,
                  child: Text(
                    _tabs[i],
                    style: AppText.label.copyWith(
                      fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w600,
                      color: _tab == i ? AppColors.green : AppColors.ink55,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text.toUpperCase(),
        style: AppText.label.copyWith(color: AppColors.ink55, letterSpacing: 0.3));
  }

  Widget _bookingCard({
    required String title,
    required String status,
    required Color statusBg,
    required Color statusFg,
    String? avatarInitials,
    required String sub,
    required String price,
  }) {
    return GwCard(
      onTap: () => context.push('/booking/edit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: AppText.cardTitle)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status,
                    style: AppText.tag.copyWith(fontSize: 11, color: statusFg)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (avatarInitials != null)
                InitialsAvatar(avatarInitials, size: 28, fontSize: 11)
              else
                const PhotoPlaceholder(width: 28, height: 28, radius: 14),
              const SizedBox(width: 10),
              Text(sub,
                  style: AppText.body
                      .copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink60)),
            ],
          ),
          const SizedBox(height: 10),
          Text(price, style: AppText.price),
        ],
      ),
    );
  }
}
