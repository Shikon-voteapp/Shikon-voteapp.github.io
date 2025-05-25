import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String message;

  const InfoDialog({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Theme.of(context).primaryColor, // テーマのプライマリカラーを使用
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 100, // OKボタンの幅を調整
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
          ),
        ),
      ],
    );
  }
}
