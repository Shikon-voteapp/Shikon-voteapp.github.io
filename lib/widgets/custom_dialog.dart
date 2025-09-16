import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shikon_voteapp/screens/admin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  String? content,
  Widget? contentWidget,
  VoidCallback? onPrimaryAction,
  String? primaryActionText,
  String closeButtonText = '閉じる',
  String? imagePath,
  List<Widget>? actions,
  bool showWikiLink = false,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return CustomDialogWidget(
        title: title,
        content: content,
        contentWidget: contentWidget,
        onPrimaryAction: onPrimaryAction,
        primaryActionText: primaryActionText,
        closeButtonText: closeButtonText,
        imagePath: imagePath,
        actions: actions,
        showWikiLink: showWikiLink,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

Future<void> showAdminLoginDialog({required BuildContext context}) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder: (context, setState) {
          return CustomDialogWidget(
            title: '管理者ログイン',
            contentWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            primaryActionText: 'ログイン',
            onPrimaryAction:
                isLoading
                    ? null
                    : () async {
                      if (emailController.text.isEmpty ||
                          passwordController.text.isEmpty) {
                        showCustomDialog(
                          context: context,
                          title: '入力エラー',
                          content: 'メールアドレスとパスワードを入力してください。',
                          closeButtonText: 'OK',
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      try {
                        await auth.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text,
                        );
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => AdminScreen(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        Navigator.of(
                          context,
                        ).pop(); // Close dialog before showing new one
                        String message;
                        if (e.code == 'user-not-found' ||
                            e.code == 'wrong-password' ||
                            e.code == 'invalid-credential') {
                          message = 'メールアドレスまたはパスワードが正しくありません。';
                        } else {
                          message = 'ログインに失敗しました。(${e.code})';
                        }
                        showCustomDialog(
                          context: context,
                          title: 'ログインエラー',
                          content: message,
                          closeButtonText: 'OK',
                        );
                      } finally {
                        if (context.mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
          );
        },
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class CustomDialogWidget extends StatelessWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionText;
  final String closeButtonText;
  final String? imagePath;
  final List<Widget>? actions;
  final bool showWikiLink;

  const CustomDialogWidget({
    Key? key,
    required this.title,
    this.content,
    this.contentWidget,
    this.onPrimaryAction,
    this.primaryActionText,
    this.closeButtonText = '閉じる',
    this.imagePath,
    this.actions,
    this.showWikiLink = false,
  }) : assert(content != null || contentWidget != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isSmallHeight = media.size.height < 700;
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: AnimationLimiter(
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      color: theme.colorScheme.surface,
                      depth: 4,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(30.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 画像
                        if (imagePath != null &&
                            !isSmallHeight &&
                            _shouldShowImage(context)) ...[
                          AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 300),
                            child: FadeInAnimation(
                              child: SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    imagePath!,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .secondaryContainer,
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final maxScrollHeight =
                                MediaQuery.of(context).size.height * 0.6;
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: maxScrollHeight,
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    contentWidget ??
                                        Text(
                                          content ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                          ),
                                        ),
                                    if (showWikiLink) ...[
                                      const SizedBox(height: 16),
                                      NeumorphicButton(
                                        onPressed: () {
                                          final url =
                                              'https://shikon-voteapp.github.io/information/';
                                          if (kIsWeb) {
                                            html.window.open(url, '_blank');
                                          }
                                        },
                                        style: NeumorphicStyle(
                                          depth: 2,
                                          intensity: 0.8,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              HugeIcons
                                                  .strokeRoundedExternalLink01,
                                              size: 16,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '詳細情報',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (actions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: actions!,
                )
              else
                Row(
                  mainAxisAlignment:
                      onPrimaryAction == null
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
                  children: [
                    NeumorphicButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: NeumorphicStyle(
                        depth: 2,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(30.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.close),
                          const SizedBox(width: 8),
                          Text(closeButtonText),
                        ],
                      ),
                    ),
                    if (onPrimaryAction != null && primaryActionText != null)
                      NeumorphicButton(
                        onPressed: () => onPrimaryAction!(),
                        style: NeumorphicStyle(
                          color: Colors.black,
                          depth: 6,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              primaryActionText!,
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 特定の画面では画像を表示しない
  bool _shouldShowImage(BuildContext context) {
    final route = ModalRoute.of(context);
    final settingsName = route?.settings.name ?? '';

    final widgetType = context.widget.runtimeType.toString();
    const hiddenNames = ['/scanner', '/top', '/confirm'];
    const hiddenWidgets = [
      'ScannerScreen',
      'StudentVerificationScreen',
      'ConfirmScreen',
    ];

    if (hiddenNames.any((n) => settingsName.contains(n))) return false;
    if (hiddenWidgets.any((w) => widgetType.contains(w))) return false;
    return true;
  }
}
