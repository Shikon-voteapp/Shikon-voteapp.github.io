// main.dart
import 'package:flutter/material.dart';
import 'screens/scanner_screen.dart';

void main() {
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
