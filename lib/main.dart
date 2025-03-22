import 'package:flutter/material.dart';
import 'scanner_page.dart';
import 'vote_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文化祭投票',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScannerPage(),
    );
  }
}
