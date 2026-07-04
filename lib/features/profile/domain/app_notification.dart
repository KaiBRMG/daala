/// Notification activity types (DESIGN.md §3.13 Notifications).
enum NotificationType { offerReceived, booking, escrow, dispute, review }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.unread,
    required this.targetRoute,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool unread;

  /// Deep target the row navigates to.
  final String targetRoute;
}
