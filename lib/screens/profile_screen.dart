import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            const SizedBox(height: 6),
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 22, bottom: 120),
                children: [
                  _identity(),
                  const SizedBox(height: 22),
                  _stats(),
                  const SizedBox(height: 18),
                  GwCard(
                    child: Text(
                      'Handy with tools, quick with logos. I take on moving, garden and small design gigs around Fitzroy — reliable and always on time.',
                      style: AppText.body,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      TagPill('Gardening'),
                      TagPill('Moving'),
                      TagPill('Design'),
                      TagPill('Delivery'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Reviews',
                      style: AppText.section.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  _review('Ana R.',
                      '"Showed up early and got the shelving done fast. Would book again."'),
                  const SizedBox(height: 10),
                  _review('Theo B.',
                      '"Great communication, delivered the logo concepts a day early."'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Text('Profile',
              textAlign: TextAlign.center, style: AppText.appBarTitle),
        ),
        RoundIconButton(
          icon: Icons.account_balance_wallet_outlined,
          iconSize: 16,
          onTap: () => context.push('/wallet'),
        ),
      ],
    );
  }

  Widget _identity() {
    return Column(
      children: [
        const InitialsAvatar('JD', size: 84, fontSize: 28),
        const SizedBox(height: 12),
        Text('Jordan Dae',
            style: AppText.metaStrong
                .copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('★ 4.9 · 128 reviews',
            style: AppText.tag.copyWith(color: AppColors.orange, fontSize: 13)),
      ],
    );
  }

  Widget _stats() {
    return Row(
      children: [
        Expanded(child: _statCard('62', 'Gigs Done')),
        const SizedBox(width: 10),
        Expanded(child: _statCard('98%', 'Response')),
        const SizedBox(width: 10),
        Expanded(child: _statCard('2023', 'Member Since')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return GwCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value,
              style: AppText.metaStrong
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: AppText.meta.copyWith(
                  fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink50)),
        ],
      ),
    );
  }

  Widget _review(String author, String body) {
    return GwCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhotoPlaceholder(width: 28, height: 28, radius: 14),
              const SizedBox(width: 10),
              Text(author,
                  style: AppText.tag.copyWith(fontSize: 13, color: AppColors.ink)),
              const Spacer(),
              Text('★★★★★',
                  style: AppText.tag
                      .copyWith(fontSize: 12, color: AppColors.orange)),
            ],
          ),
          const SizedBox(height: 6),
          Text(body,
              style: AppText.body.copyWith(
                  fontSize: 12, height: 1.5, color: AppColors.ink60)),
        ],
      ),
    );
  }
}
