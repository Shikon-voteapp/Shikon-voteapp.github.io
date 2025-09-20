import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shikon_voteapp/screens/admin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  String? content,
  Widget? contentWidget,
  VoidCallback? onPrimaryAction,
  String? primaryActionText,
  String? closeButtonText = '閉じる',
  String? imagePath,
  List<Widget>? actions,
  bool showWikiLink = false,
  bool enablePrimaryLoading = false,
  int minLoadingMs = 0,
  int maxLoadingMs = 0,
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
        enablePrimaryLoading: enablePrimaryLoading,
        minLoadingMs: minLoadingMs,
        maxLoadingMs: maxLoadingMs,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メールアドレス',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'パスワード',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Neumorphic(
                      style: NeumorphicStyle(
                        depth: -4,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

class CustomDialogWidget extends StatefulWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final VoidCallback? onPrimaryAction;
  final String? primaryActionText;
  final String? closeButtonText;
  final String? imagePath;
  final List<Widget>? actions;
  final bool showWikiLink;
  final bool enablePrimaryLoading;
  final int minLoadingMs;
  final int maxLoadingMs;

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
    this.enablePrimaryLoading = false,
    this.minLoadingMs = 0,
    this.maxLoadingMs = 0,
  }) : assert(content != null || contentWidget != null),
       super(key: key);

  @override
  State<CustomDialogWidget> createState() => _CustomDialogWidgetState();
}

class _CustomDialogWidgetState extends State<CustomDialogWidget> {
  bool _primaryLoading = false;

  Future<void> _handlePrimaryPressed() async {
    if (_primaryLoading) return;
    setState(() => _primaryLoading = true);
    if (widget.enablePrimaryLoading) {
      final int minMs = widget.minLoadingMs > 0 ? widget.minLoadingMs : 1300;
      final int maxMs = widget.maxLoadingMs > 0 ? widget.maxLoadingMs : 1700;
      final int span = (maxMs - minMs).clamp(0, 10000);
      final int rnd =
          minMs + (DateTime.now().microsecondsSinceEpoch % (span + 1));
      await Future.delayed(Duration(milliseconds: rnd));
    }
    if (!mounted) return;
    widget.onPrimaryAction?.call();
    setState(() => _primaryLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isSmallHeight = media.size.height < 700;
    return SafeArea(
      child: Neumorphic(
        style: NeumorphicStyle(color: Colors.transparent, depth: 0),
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
                        // 画像（指定があれば常に表示。小さい縦幅では非表示）
                        if (widget.imagePath != null && !isSmallHeight) ...[
                          AnimationConfiguration.synchronized(
                            duration: const Duration(milliseconds: 300),
                            child: FadeInAnimation(
                              child: SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    widget.imagePath!,
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
                          widget.title,
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
                                    widget.contentWidget ??
                                        Text(
                                          widget.content ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color,
                                          ),
                                        ),
                                    if (widget.showWikiLink) ...[
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
                                          depth: 4,
                                          intensity: 0.7,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              FontAwesome
                                                  .arrow_up_right_from_square_solid,
                                              size: 16,
                                              color:
                                                  Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '詳細情報',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                        : Colors.black,
                                                fontWeight: FontWeight.w600,
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
              if (widget.actions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.actions!,
                )
              else
                Row(
                  mainAxisAlignment:
                      widget.onPrimaryAction == null
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.closeButtonText != null)
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
                            const Icon(FontAwesome.xmark_solid),
                            const SizedBox(width: 8),
                            Text(widget.closeButtonText!),
                          ],
                        ),
                      ),
                    if (widget.onPrimaryAction != null &&
                        widget.primaryActionText != null)
                      NeumorphicButton(
                        onPressed:
                            _primaryLoading ? null : _handlePrimaryPressed,
                        style: NeumorphicStyle(
                          color: Colors.black,
                          depth: 6,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(30.0),
                          ),
                        ),
                        child:
                            _primaryLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.primaryActionText!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      FontAwesome.arrow_right_solid,
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

  // 以前は画面タイプでフィルタしていたが、画像指定があれば表示する方針に変更
}
