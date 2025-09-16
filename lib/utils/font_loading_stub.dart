import 'dart:async';

/// Non-web platforms: no special font waiting needed.
Future<void> waitForWebFonts({
  Duration fallback = const Duration(milliseconds: 2200),
}) async {
  // On non-web, just return immediately. If you prefer to keep timing consistent
  // with web fallback, uncomment the next line.
  // await Future.delayed(fallback);
}
