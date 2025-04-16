import 'package:flutter/material.dart';
import 'admin_access.dart';

class BottomBar extends StatelessWidget {
  final String uuid;
  final bool showNextButton;
  final bool showBackButton;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  BottomBar({
    required this.uuid,
    this.showNextButton = true,
    this.showBackButton = false,
    this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(timeStr, style: TextStyle(color: Colors.white)),
              SizedBox(width: 16),
              Text(
                'ID:${uuid.isEmpty ? '-----' : uuid.substring(0, 10)}',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 16),
              AdminAccessButton(),
            ],
          ),
          Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        Text(
                          '前に戻る',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        ],
      ),
    );
  }
}
