import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/scanner_screen.dart';
import 'screens/admin_screen.dart';
import 'firebase_options.dart'; // Firebase CLIで生成されるファイル
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase の初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // オフライン対応設定
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // アプリ起動時にデータベース同期
  final dbService = DatabaseService();
  await dbService.syncFromFirebase();
  runApp(VoteApp());
}

class VoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文化祭投票アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM Plex Sans JP',
      ),
      home: ScannerScreen(),
    );
  }
}
