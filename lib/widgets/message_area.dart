// widgets/message_area.dart
import 'package:flutter/material.dart';

var MainTitle = "紫紺祭";

class MessageArea extends StatelessWidget {
  final String message;
  final String title;
  final Color? titleColor;
  final IconData? icon;

  MessageArea({
    required this.message,
    required this.title,
    this.titleColor = const Color(0xFF483D8B),
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Color(0xFFF0F0F0),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Text(
            title ?? '',
            style: TextStyle(
              color: titleColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: titleColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child:
                  icon != null
                      ? Icon(icon, size: 16, color: Colors.white)
                      : Text('?', style: TextStyle(color: Colors.white)),
            ),
          ),
          SizedBox(width: 16),
          Expanded(child: Text(message, style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}
