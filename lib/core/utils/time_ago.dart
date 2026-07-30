/// Formats a [DateTime] as a human-readable relative time string.
String formatTimeAgo(DateTime dateTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Posted just now';
  }
  if (difference.inHours < 1) {
    final minutes = difference.inMinutes;
    return 'Posted $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'Posted $hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
  if (difference.inDays == 1) {
    return 'Posted yesterday';
  }
  if (difference.inDays < 7) {
    return 'Posted ${difference.inDays} days ago';
  }

  return 'Posted on ${dateTime.day}/${dateTime.month}/${dateTime.year}';
}

/// Formats sold listings with a "Sold" prefix.
String formatSoldTimeAgo(DateTime dateTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(dateTime);

  if (difference.inDays == 0) {
    return 'Sold today';
  }
  if (difference.inDays == 1) {
    return 'Sold yesterday';
  }
  if (difference.inDays < 7) {
    return 'Sold ${difference.inDays} days ago';
  }

  return 'Sold on ${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
