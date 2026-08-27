import 'package:firebase_auth/firebase_auth.dart';
import 'package:shikon_voteapp/screens/admin_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// TODO: Migrate to package:web when stable
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'liquid_glass.dart';

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
  String? wikiUrl,
  bool enablePrimaryLoading = false,
  int minLoadingMs = 0,
  int maxLoadingMs = 0,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
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
        wikiUrl: wikiUrl,
        enablePrimaryLoading: enablePrimaryLoading,
        minLoadingMs: minLoadingMs,
        maxLoadingMs: maxLoadingMs,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
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
    barrierColor: Colors.black.withValues(alpha: 0.5),
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
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.black.withValues(alpha: 0.2) 
                          : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? Colors.black.withValues(alpha: 0.2) 
                          : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
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
  final String? wikiUrl;
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
    this.wikiUrl,
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
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    final Widget actionsWidget = widget.actions != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.actions!,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.onPrimaryAction != null &&
                  widget.primaryActionText != null) ...[
                LiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    glassColor: isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.25),
                    thickness: 10.0,
                    blur: 10.0,
                  ),
                  child: LiquidGlass(
                    shape: LiquidRoundedRectangle(
                      borderRadius: 30.0,
                    ),
                    child: InkWell(
                      onTap: _primaryLoading ? null : _handlePrimaryPressed,
                      borderRadius: BorderRadius.circular(30.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.50),
                            width: 1.2,
                          ),
                        ),
                        child: _primaryLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: isDark
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.primaryActionText!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: isDark
                                        ? Colors.white
                                        : theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (widget.closeButtonText != null)
                LiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    glassColor: isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.25),
                    thickness: 10.0,
                    blur: 10.0,
                  ),
                  child: LiquidGlass(
                    shape: LiquidRoundedRectangle(
                      borderRadius: 30.0,
                    ),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(30.0),
                      child: Container(
                        height: 48.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              size: 18,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.closeButtonText!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: AnimationLimiter(
                child: LiquidGlassLayer(
                  settings: LiquidGlassSettings(
                    glassColor: glassColor,
                    thickness: 15.0,
                    blur: 20.0,
                  ),
                  child: LiquidGlass(
                    shape: LiquidRoundedRectangle(
                      borderRadius: 30.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.imagePath != null && !isSmallHeight) ...[
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 300),
                                child: FadeInAnimation(
                                  child: Center(
                                    child: SizedBox(
                                      height: 120,
                                      width: double.infinity,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
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
                                    MediaQuery.of(context).size.height * 0.45;
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: maxScrollHeight,
                                  ),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          LiquidGlassLayer(
                                            settings: LiquidGlassSettings(
                                              glassColor: isDark
                                                  ? Colors.white.withValues(alpha: 0.08)
                                                  : Colors.black.withValues(alpha: 0.04),
                                              thickness: 8.0,
                                              blur: 10.0,
                                            ),
                                            child: LiquidGlass(
                                              shape: LiquidRoundedRectangle(
                                                borderRadius: 24.0,
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  final url =
                                                      widget.wikiUrl ??
                                                      'https://shikon-voteapp.github.io/information/';
                                                  if (kIsWeb) {
                                                    html.window.open(url, '_blank');
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(24.0),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 10.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.open_in_new,
                                                        size: 15,
                                                        color: theme.colorScheme.onSurface,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '詳細情報',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                          color: theme.colorScheme.onSurface,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            actionsWidget,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 以前は画面タイプでフィルタしていたが、画像指定があれば表示する方針に変更
}
