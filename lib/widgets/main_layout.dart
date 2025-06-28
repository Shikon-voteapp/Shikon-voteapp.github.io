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

  const MainLayout({
    Key? key,
    required this.title,
    required this.child,
    this.onHome,
    this.onInfo,
    this.onBack,
    this.onNext,
    this.helpUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopBar(title: title),
          Expanded(child: child),
          BottomBar(onBack: onBack, onNext: onNext, helpUrl: helpUrl),
        ],
      ),
    );
  }
}
