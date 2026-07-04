import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';

/// Intent select — sets the default Consumer/Merchant mode
/// (DESIGN.md §3.12). Both modes remain available on one account.
class IntentSelectScreen extends ConsumerWidget {
  const IntentSelectScreen({super.key});

  void _choose(BuildContext context, WidgetRef ref, UserMode mode) {
    ref.read(sessionProvider).setMode(mode);
    context.push(RoutePaths.signup);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DaalaSpacing.s32),
              Text('What brings you to Daala?',
                  style:
                      DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
              const SizedBox(height: DaalaSpacing.s8),
              Text('You can always do both — one account works both ways.',
                  style: DaalaTextStyles.body
                      .copyWith(color: DaalaColors.ink500)),
              const SizedBox(height: DaalaSpacing.s32),
              _IntentCard(
                icon: Icons.checklist_outlined,
                title: UserMode.consumer.intentLabel,
                body:
                    'Post a Gig Request and hire trusted local Merchants.',
                onTap: () => _choose(context, ref, UserMode.consumer),
              ),
              const SizedBox(height: DaalaSpacing.s16),
              _IntentCard(
                icon: Icons.handyman_outlined,
                title: UserMode.merchant.intentLabel,
                body: 'Offer your services with a Gig Post and get paid.',
                onTap: () => _choose(context, ref, UserMode.merchant),
              ),
              const Spacer(),
              DaalaButton(
                label: "I'll do both",
                variant: DaalaButtonVariant.tertiary,
                // TODO(spec): default mode for "I'll do both" unspecified —
                // defaults to Consumer.
                onPressed: () => _choose(context, ref, UserMode.consumer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntentCard extends StatelessWidget {
  const _IntentCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DaalaCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DaalaSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: DaalaSizes.emptyStateIcon,
              color: DaalaColors.brandGreen900),
          const SizedBox(height: DaalaSpacing.s16),
          Text(title,
              style: DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          const SizedBox(height: DaalaSpacing.s4),
          Text(body,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink700)),
        ],
      ),
    );
  }
}
