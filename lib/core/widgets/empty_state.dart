import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Standard empty state (DESIGN.md §3 global conventions): muted outline
/// icon, `h3` headline, `body` subtext, optional button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.headline,
    required this.subtext,
    this.action,
  });

  final IconData icon;
  final String headline;
  final String subtext;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DaalaSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: DaalaSizes.emptyStateIcon, color: DaalaColors.ink300),
            const SizedBox(height: DaalaSpacing.s16),
            Text(
              headline,
              style:
                  DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DaalaSpacing.s8),
            Text(
              subtext,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink500),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: DaalaSpacing.s24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
