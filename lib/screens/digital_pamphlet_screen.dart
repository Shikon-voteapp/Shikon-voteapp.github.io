import 'package:flutter/material.dart';

class DigitalPamphletScreen extends StatelessWidget {
  const DigitalPamphletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('デジタルパンフレット')),
      body: const Center(
        child: Text('この機能は現在準備中です。', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
