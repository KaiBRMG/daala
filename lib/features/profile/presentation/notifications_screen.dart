import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/profile_providers.dart';
import '../domain/app_notification.dart';

/// Notifications — activity log (DESIGN.md §3.13). Unread = orange dot;
/// tap → deep target.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.offerReceived:
        return Icons.local_offer_outlined;
      case NotificationType.booking:
        return Icons.event_available_outlined;
      case NotificationType.escrow:
        return Icons.shield_outlined;
      case NotificationType.dispute:
        return Icons.gavel_outlined;
      case NotificationType.review:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Notifications',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: notifications.when(
        loading: () => Shimmer(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (_, _) => const ListRowSkeleton(),
          ),
        ),
        error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(notificationsProvider)),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none,
                headline: "You're all caught up",
                subtext: 'New activity on your gigs will appear here.',
              )
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final notification = list[i];
                  return DaalaListRow(
                    leading: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        LeadingCircleIcon(
                            icon: _iconFor(notification.type)),
                        if (notification.unread)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: DaalaSpacing.s8,
                              height: DaalaSpacing.s8,
                              decoration: const BoxDecoration(
                                color: DaalaColors.accentOrange500,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: notification.title,
                    subtitle: notification.body,
                    trailing: Text(
                        formatRelative(notification.timestamp),
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500)),
                    onTap: () =>
                        context.push(notification.targetRoute),
                  );
                },
              ),
      ),
    );
  }
}
