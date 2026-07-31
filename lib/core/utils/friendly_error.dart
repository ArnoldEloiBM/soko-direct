
/// Maps low-level errors into user-facing messages.
String friendlyErrorMessage(Object error) {
  final message = error.toString().toLowerCase();

  if (message.contains('network') || message.contains('connection')) {
    return 'Check your internet connection and try again.';
  }
  if (message.contains('permission') || message.contains('denied')) {
    return 'You do not have permission to do that.';
  }
  if (message.contains('not signed in') ||
      message.contains('unauthenticated')) {
    return 'Please sign in and try again.';
  }
  if (message.contains('not found')) {
    return 'That listing could not be found.';
  }

  return 'Something went wrong. Please try again.';
}
