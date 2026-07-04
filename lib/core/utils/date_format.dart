const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// `12 Jun` / `12 Jun 2025` when in a different year.
String formatShortDate(DateTime date) {
  final now = DateTime.now();
  final base = '${date.day} ${_months[date.month - 1]}';
  return date.year == now.year ? base : '$base ${date.year}';
}

/// `14:05`.
String formatTime(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

/// Relative label for timestamps: `Just now`, `12m ago`, `3h ago`,
/// `2d ago`, else a short date.
String formatRelative(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatShortDate(date);
}
