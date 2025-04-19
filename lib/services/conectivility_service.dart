import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class ConnectivityService {
  final DatabaseService _dbService = DatabaseService();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  bool _wasOffline = false;

  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        if (_wasOffline) {
          await _dbService.syncToFirebase();
          _wasOffline = false;
        }
      } else {
        _wasOffline = true;
      }
    });

    FirebaseDatabase.instance.ref('.info/connected').onValue.listen((event) {
      bool connected = event.snapshot.value as bool? ?? false;
      if (connected && _wasOffline) {
        _dbService.syncToFirebase();
        _wasOffline = false;
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  Future<void> syncNow() async {
    await _dbService.syncToFirebase();
  }
}
