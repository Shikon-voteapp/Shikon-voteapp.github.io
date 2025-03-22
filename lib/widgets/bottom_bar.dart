// widgets/bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BottomBar extends StatelessWidget {
  final String uuid;
  final bool showNextButton;
  final VoidCallback? onNext;

  BottomBar({required this.uuid, this.showNextButton = true, this.onNext});

  @override
  Widget build(BuildContext context) {
    // 現在の日時を取得
    final now = DateTime.now();
    final dateStr = '${now.year}年${now.month}月${now.day}日';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(dateStr, style: TextStyle(color: Colors.white)),
              SizedBox(width: 16),
              Text(
                'ID:${uuid.isEmpty ? '-----' : uuid.substring(0, 6)}',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 16),
              Text(timeStr, style: TextStyle(color: Colors.white)),
            ],
          ),
          if (showNextButton)
            GestureDetector(
              onTap: onNext,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '次へ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
