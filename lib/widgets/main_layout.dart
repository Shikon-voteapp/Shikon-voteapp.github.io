import 'package:flutter/material.dart';

import 'package:shikon_voteapp/widgets/bottom_bar.dart';
import 'package:shikon_voteapp/widgets/top_bar.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onHome;
  final VoidCallback? onInfo;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextLoading;
  final String? helpUrl;
  final String? helpTitle;
  final String? helpContent;
  final IconData? icon;
  final bool extendBehindBottomBar;

  const MainLayout({
    Key? key,
    required this.title,
    required this.child,
    this.onHome,
    this.onInfo,
    this.onBack,
    this.onNext,
    this.nextLabel = '次へ',
    this.nextLoading = false,
    this.helpUrl,
    this.helpTitle,
    this.helpContent,
    this.icon,
    this.extendBehindBottomBar = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget bottomBarWidget = BottomBar(
      onBack: onBack,
      onNext: onNext,
      nextLabel: nextLabel,
      nextLoading: nextLoading,
      onHome: onHome,
      helpUrl: helpUrl,
      helpTitle: helpTitle,
      helpContent: helpContent,
      infoExtraText:
          'このアプリケーションでは、読みやすくまちがえにくいUDフォントを採用しています。\n使用フォント：モリサワ　UD新ゴ',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: extendBehindBottomBar
          ? Stack(
              children: [
                Positioned.fill(
                  child: child,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: TopBar(title: title, icon: icon ?? Icons.person_outline),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: bottomBarWidget,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TopBar(title: title, icon: icon ?? Icons.person_outline),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: child),
                      bottomBarWidget,
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
