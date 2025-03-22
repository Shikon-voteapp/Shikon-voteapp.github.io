// services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class ConnectivityService {
  final DatabaseService _dbService = DatabaseService();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  bool _wasOffline = false;

  // 接続監視を開始
  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        // ネットワークに接続された
        if (_wasOffline) {
          // オフラインから復帰した場合、データを同期
          await _dbService.syncToFirebase();
          _wasOffline = false;
        }
      } else {
        // ネットワーク接続が切断された
        _wasOffline = true;
      }
    });

    // Firebase の接続状態も監視
    FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
      bool connected = event.snapshot.value as bool? ?? false;
      if (connected && _wasOffline) {
        // Firebase に再接続された場合
        _dbService.syncToFirebase();
        _wasOffline = false;
      }
    });
  }

  // 監視を停止（アプリ終了時など）
  void stopMonitoring() {
    _subscription?.cancel();
  }

  // 手動同期を実行
  Future<void> syncNow() async {
    await _dbService.syncToFirebase();
  }
}
