import 'package:flutter/material.dart';
import 'info_dialog.dart'; // 作成した InfoDialog をインポート

// var MainTitle = "紫紺祭"; // この変数は MessageArea では使用されていないようです

class MessageArea extends StatefulWidget {
  // StatelessWidget から StatefulWidget に変更
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
  _MessageAreaState createState() => _MessageAreaState();
}

class _MessageAreaState extends State<MessageArea> {
  bool _showDescription = false;
  final double _widthThreshold = 600.0; // 説明表示を切り替える画面幅の閾値

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final bool isNarrowScreen = screenWidth < _widthThreshold;

      if (isNarrowScreen) {
        // SnackBar の代わりに InfoDialog を表示
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return InfoDialog(title: widget.title, message: widget.message);
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < _widthThreshold;

    // 狭い画面で初めてビルドされるとき、説明を非表示にする（ただし、既に表示状態ならそのまま）
    // このロジックは initState の方が適切かもしれないが、ここでは build 内で処理
    // if (isNarrowScreen && !_descriptionInitiallySetForNarrowScreen) {
    //   _showDescription = false;
    //   _descriptionInitiallySetForNarrowScreen = true;
    // }

    return Container(
      width: double.infinity,
      color: Color(0xFFF0F0F0),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // アイコンとタイトルを上揃えに
        children: [
          Text(
            widget.title ?? '',
            style: TextStyle(
              color: widget.titleColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          // IconButton に変更してタップ可能に
          IconButton(
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: widget.titleColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child:
                    widget.icon != null
                        ? Icon(widget.icon, size: 16, color: Colors.white)
                        : Text(
                          '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            onPressed: () {
              if (isNarrowScreen) {
                // 狭い画面の場合のみトグル
                setState(() {
                  _showDescription = !_showDescription;
                });
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(), // IconButton のデフォルトパディングを削除
          ),
          SizedBox(width: 16),
          Expanded(
            // Visibility で説明文の表示を制御
            child: Visibility(
              visible:
                  !isNarrowScreen ||
                  _showDescription, // 広い画面か、狭い画面で _showDescription が true なら表示
              child: Text(widget.message, style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
