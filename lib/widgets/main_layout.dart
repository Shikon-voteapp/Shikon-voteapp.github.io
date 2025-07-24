import 'package:flutter/material.dart';
import 'package:shikon_voteapp/widgets/bottom_bar.dart';
import 'package:shikon_voteapp/widgets/top_bar.dart';
import 'package:shikon_voteapp/theme.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onHome;
  final VoidCallback? onInfo;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? helpUrl;
  final String? helpTitle;
  final String? helpContent;
  final IconData? icon;

  const MainLayout({
    Key? key,
    required this.title,
    required this.child,
    this.onHome,
    this.onInfo,
    this.onBack,
    this.onNext,
    this.helpUrl,
    this.helpTitle,
    this.helpContent,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBar(title: title, icon: icon ?? Icons.person_outline),
          Expanded(child: child),
          BottomBar(
            onBack: onBack,
            onNext: onNext,
            onHome: onHome,
            helpUrl: helpUrl,
            helpTitle: helpTitle,
            helpContent: helpContent,
          ),
        ],
      ),
    );
  }
}
