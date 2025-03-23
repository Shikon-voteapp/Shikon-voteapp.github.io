// widgets/top_bar.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../screens/scanner_screen.dart';
import 'dart:html' as html;

void reloadPage() {
  html.window.location.reload();
}

class TopBar extends StatelessWidget {
  final String title;

  TopBar({this.title = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 戻るボタン
            GestureDetector(
              onTap: () {
                _showResetConfirmation(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      '最初から',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (title.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

            // 係員を呼ぶボタン
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('最初からやりなおしますか？'),
            content: Text('現在の投票内容はすべて消去されます。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('いいえ'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // 既存の関数を呼び出す
                  reloadPage();
                },
                child: Text('はい'),
              ),
            ],
          ),
    );
  }
}
