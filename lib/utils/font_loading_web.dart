import 'dart:async';

Future<void> waitForWebFonts({
  Duration fallback = const Duration(milliseconds: 2200),
}) async {
  // dart:html の型では ready が定義されていない環境があるため、
  // CSS Font Loading API の代替としてフォントの使用を試み、
  // 最低限の遅延のみを入れる。
  await Future.delayed(fallback);
}
