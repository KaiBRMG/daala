import 'package:flutter/material.dart';

import '../models/lifecycle_state.dart';
import '../theme/tokens.dart';

/// Status badge pill — `overline` text, fg + bg semantic pair per
/// DESIGN.md §1.2 / §2.4.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.state});

  final LifecycleState state;

  static (Color fg, Color bg) colorsFor(LifecycleState state) {
    switch (state) {
      case LifecycleState.open:
      case LifecycleState.active:
        return (DaalaColors.statusOpen, DaalaColors.statusOpenBg);
      case LifecycleState.offerAccepted:
      case LifecycleState.booked:
        return (DaalaColors.statusPending, DaalaColors.statusPendingBg);
      case LifecycleState.inEscrow:
        return (DaalaColors.statusEscrow, DaalaColors.statusEscrowBg);
      case LifecycleState.inProgress:
        return (DaalaColors.statusProgress, DaalaColors.statusProgressBg);
      case LifecycleState.completed:
        return (DaalaColors.statusSuccess, DaalaColors.statusSuccessBg);
      case LifecycleState.disputed:
        return (DaalaColors.statusDispute, DaalaColors.statusDisputeBg);
      case LifecycleState.resolved:
      case LifecycleState.cancelled:
      case LifecycleState.expired:
      case LifecycleState.paused:
        return (DaalaColors.statusNeutral, DaalaColors.statusNeutralBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = colorsFor(state);
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: DaalaSpacing.s4, horizontal: DaalaSpacing.s8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DaalaRadius.rPill),
      ),
      child: Text(state.badgeLabel,
          style: DaalaTextStyles.overline.copyWith(color: fg)),
    );
  }
}
