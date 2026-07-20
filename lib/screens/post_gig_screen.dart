import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class PostGigScreen extends StatelessWidget {
  const PostGigScreen({super.key});

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
            Text('Set up your gig to find the right help',
                style: AppText.postTitle),
            const SizedBox(height: 8),
            Text('Add details so taskers know what to expect.',
                style: AppText.metaStrong.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink50)),
            const SizedBox(height: 22),
            _fieldLabel('Category'),
            const SizedBox(height: 8),
            GwCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const PhotoPlaceholder(width: 56, height: 56),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Home & Garden', style: AppText.cardTitle),
                      const SizedBox(height: 2),
                      Text('Moving · One-time', style: AppText.meta),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _fieldLabel('Budget'),
            const SizedBox(height: 8),
            GwCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            color: AppColors.greenTint, shape: BoxShape.circle),
                        child: const Text('💰', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Text('Budget Range',
                          style: AppText.metaStrong
                              .copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text('\$65–\$90',
                      style: AppText.metaStrong
                          .copyWith(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _fieldLabel('Pricing Type'),
            const SizedBox(height: 10),
            _twoOptions('Fixed Price', 'Hourly Rate'),
            const SizedBox(height: 22),
            _fieldLabel('Schedule'),
            const SizedBox(height: 10),
            _twoOptions('One-time', 'Recurring'),
            const SizedBox(height: 22),
            _reachCard(),
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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppShadows.soft,
          ),
          child: Text('Get Help',
              style: AppText.tag.copyWith(fontSize: 13, color: AppColors.green)),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) =>
      Text(text, style: AppText.label);

  Widget _twoOptions(String active, String inactive) {
    Widget option(String text, bool sel) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sel ? null : AppColors.trackFill,
            borderRadius: BorderRadius.circular(22),
            border: sel ? Border.all(color: AppColors.green, width: 2) : null,
          ),
          child: Text(
            text,
            style: AppText.metaStrong.copyWith(
              fontSize: 14,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w600,
              color: sel ? AppColors.green : AppColors.ink40,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(active, true),
        const SizedBox(width: 10),
        option(inactive, false),
      ],
    );
  }

  Widget _reachCard() {
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
              child: _cell('Estimated Reach', '40 taskers', AppColors.ink),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _cell('Suggested Price', '\$72', AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: AppText.meta.copyWith(
                fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink50)),
        const SizedBox(height: 6),
        Text(value,
            style: AppText.money.copyWith(fontSize: 20, color: color)),
      ],
    );
  }

  Widget _cta() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadows.greenCta,
      ),
      child: Text('Post Gig',
          style: AppText.metaStrong.copyWith(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.white)),
    );
  }
}
