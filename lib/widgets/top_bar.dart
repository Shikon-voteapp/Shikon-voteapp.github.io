import 'package:flutter/material.dart';
import '../platform/platform_utils.dart';

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
                    Icon(Icons.delete_forever, color: Colors.black),
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
                  PlatformUtils.reloadApp();
                },
                child: Text('はい'),
              ),
            ],
          ),
    );
  }
}
