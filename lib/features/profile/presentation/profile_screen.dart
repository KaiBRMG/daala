import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_posters.dart';
import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/daala_segmented.dart';

/// Own Profile (tab 5). DESIGN.md gives no exhaustive §3 spec for this
/// screen — per §2.2 it carries the Consumer ⇄ Merchant mode switch and
/// links to Wallet / Notifications / Settings.
// TODO(spec): own-profile layout unspecified — minimal token-consistent
// header + mode switch + sub-screen links.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(DaalaSpacing.screenH),
            children: [
              Text('Profile',
                  style:
                      DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
              const SizedBox(height: DaalaSpacing.s24),
              Row(
                children: [
                  const DaalaAvatar(
                      name: MockSession.displayName,
                      size: DaalaSizes.avatarLg),
                  const SizedBox(width: DaalaSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(MockSession.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: DaalaTextStyles.h3.copyWith(
                                      color: DaalaColors.ink900)),
                            ),
                            if (session.isVerified) ...[
                              const SizedBox(width: DaalaSpacing.s4),
                              const Icon(Icons.verified,
                                  size: DaalaSizes.iconSm,
                                  color: DaalaColors.brandGreen700),
                            ],
                          ],
                        ),
                        Text(
                          '⭐ ${MockPosters.me.ratingAvg.toStringAsFixed(1)} '
                          '(${MockPosters.me.reviewCount}) · Member since '
                          '${MockPosters.me.memberSince ?? '—'}',
                          style: DaalaTextStyles.caption
                              .copyWith(color: DaalaColors.ink500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DaalaSpacing.s24),
              Text('MODE',
                  style: DaalaTextStyles.overline
                      .copyWith(color: DaalaColors.ink500)),
              const SizedBox(height: DaalaSpacing.s8),
              DaalaSegmented(
                expanded: true,
                segments: const ['Consumer', 'Merchant'],
                selectedIndex:
                    session.mode == UserMode.consumer ? 0 : 1,
                onChanged: (i) => session.setMode(
                    i == 0 ? UserMode.consumer : UserMode.merchant),
              ),
              const SizedBox(height: DaalaSpacing.s8),
              Text(
                session.mode == UserMode.consumer
                    ? 'You browse as a Consumer — book Gig Posts and '
                        'post Gig Requests.'
                    : 'You browse as a Merchant — make Offers and '
                        'publish Gig Posts.',
                style: DaalaTextStyles.caption
                    .copyWith(color: DaalaColors.ink500),
              ),
              const SizedBox(height: DaalaSpacing.sectionGap),
              if (!session.isVerified)
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: DaalaSpacing.s16),
                  child: DaalaCard(
                    color: DaalaColors.accentOrange50,
                    borderColor: DaalaColors.accentOrange50,
                    onTap: () =>
                        context.push(RoutePaths.verifyIdentity),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_outlined,
                            color: DaalaColors.accentOrange600,
                            size: DaalaSizes.iconLg),
                        const SizedBox(width: DaalaSpacing.s12),
                        Expanded(
                          child: Text(
                            'Verify your identity to unlock your badge',
                            style: DaalaTextStyles.label
                                .copyWith(color: DaalaColors.ink900),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: DaalaColors.ink500,
                            size: DaalaSizes.iconLg),
                      ],
                    ),
                  ),
                ),
              DaalaCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    DaalaListRow(
                      leading: const LeadingCircleIcon(
                          icon: Icons.account_balance_wallet_outlined),
                      title: 'Wallet',
                      subtitle: 'Balance, Escrow held, transactions',
                      trailing: const Icon(Icons.chevron_right,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                      onTap: () => context.push(RoutePaths.wallet),
                    ),
                    DaalaListRow(
                      leading: const LeadingCircleIcon(
                          icon: Icons.notifications_outlined),
                      title: 'Notifications',
                      trailing: const Icon(Icons.chevron_right,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                      onTap: () =>
                          context.push(RoutePaths.notifications),
                    ),
                    DaalaListRow(
                      leading: const LeadingCircleIcon(
                          icon: Icons.settings_outlined),
                      title: 'Settings',
                      showDivider: false,
                      trailing: const Icon(Icons.chevron_right,
                          color: DaalaColors.ink500,
                          size: DaalaSizes.iconLg),
                      onTap: () => context.push(RoutePaths.settings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DaalaSpacing.s16),
              DaalaCard(
                padding: EdgeInsets.zero,
                child: DaalaListRow(
                  leading:
                      const LeadingCircleIcon(icon: Icons.person_outline),
                  title: 'View public profile',
                  subtitle: 'How others see you',
                  showDivider: false,
                  trailing: const Icon(Icons.chevron_right,
                      color: DaalaColors.ink500, size: DaalaSizes.iconLg),
                  onTap: () => context
                      .push(RoutePaths.merchant(MockSession.userId)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
