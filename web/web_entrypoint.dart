import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:shikon_voteapp/main.dart' as app;

void main() {
  // Web用のURL戦略を設定
  setUrlStrategy(PathUrlStrategy());

  // アプリケーションを起動
  app.main();
}
