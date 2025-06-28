import 'package:flutter/material.dart';
import 'custom_dialog.dart';

// var MainTitle = "紫紺祭"; // この変数は MessageArea では使用されていないようです

class MessageArea extends StatefulWidget {
  final String message;
  final String title;
  final Color? titleColor;
  final IconData? icon;
  final Color? iconColor;

  const MessageArea({
    Key? key,
    required this.message,
    required this.title,
    this.titleColor = const Color(0xFF483D8B),
    this.icon,
    this.iconColor = Colors.black54,
  }) : super(key: key);

  @override
  State<MessageArea> createState() => _MessageAreaState();
}

class _MessageAreaState extends State<MessageArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F0F0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.titleColor,
              ),
            ),
          ),
          if (widget.message.isNotEmpty)
            GestureDetector(
              onTap: () {
                showCustomDialog(
                  context: context,
                  title: widget.title,
                  content: widget.message,
                );
              },
              child: Icon(
                Icons.info_outline,
                color: widget.iconColor,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}
