import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Sticky CTA bar — the only shadowed element on a detail screen (e2).
class StickyBottomBar extends StatelessWidget {
  const StickyBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DaalaColors.bgPrimary,
        boxShadow: DaalaElevation.e2,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DaalaSpacing.s16,
              DaalaSpacing.s12, DaalaSpacing.s16, DaalaSpacing.s12),
          child: child,
        ),
      ),
    );
  }
}
