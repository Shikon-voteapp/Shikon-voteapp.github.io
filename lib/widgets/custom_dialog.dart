import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// TODO: Migrate to package:web when stable
// ignore: deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

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
  return M3EBottomSheet.show(
    context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return Material(
        color: Colors.transparent,
        child: CustomDialogWidget(
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
        ),
      );
    },
  );
}

Future<void> showAdminLoginDialog({required BuildContext context}) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  return M3EBottomSheet.show(
    context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 8.0,
                bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '管理者ログイン',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'メールアドレス',
                        prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      ),
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: M3ELoadingIndicator(
                              variant: M3ELoadingIndicatorVariant.defaultStyle,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    M3EButton(
                      onPressed: isLoading
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
                                if (context.mounted) {
                                  Navigator.of(context).pop(); // Close dialog
                                  Navigator.of(context).pushReplacementNamed('/admin');
                                }
                              } on FirebaseAuthException catch (e) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
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
                                }
                              } finally {
                                if (context.mounted) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                      style: M3EButtonStyle.filled,
                      size: M3EButtonSize.md,
                      shape: M3EButtonShape.round,
                      child: const SizedBox(
                        height: 48.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ログイン',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    M3EButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: M3EButtonStyle.tonal,
                      size: M3EButtonSize.md,
                      shape: M3EButtonShape.round,
                      child: const SizedBox(
                        height: 48.0,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 18),
                              SizedBox(width: 8),
                              Text(
                                '閉じる',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                M3EButton(
                  onPressed: _primaryLoading ? null : _handlePrimaryPressed,
                  style: M3EButtonStyle.filled,
                  size: M3EButtonSize.md,
                  shape: M3EButtonShape.round,
                  child: SizedBox(
                    height: 48.0,
                    child: Center(
                      child: _primaryLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: M3ELoadingIndicator(
                                variant: M3ELoadingIndicatorVariant.defaultStyle,
                                elevation: 0,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.primaryActionText!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (widget.closeButtonText != null)
                M3EButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: M3EButtonStyle.tonal,
                  size: M3EButtonSize.md,
                  shape: M3EButtonShape.round,
                  child: SizedBox(
                    height: 48.0,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.close, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.closeButtonText!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 8.0,
        bottom: 24.0 + media.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.imagePath != null && !isSmallHeight) ...[
            Center(
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    widget.imagePath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: theme.colorScheme.secondaryContainer,
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
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxScrollHeight = media.size.height * 0.45;
              return ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxScrollHeight),
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
                              fontSize: 15,
                              height: 1.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      if (widget.showWikiLink) ...[
                        const SizedBox(height: 16),
                        M3EButton.icon(
                          onPressed: () {
                            final url = widget.wikiUrl ?? 'https://shikon-voteapp.github.io/information/';
                            if (kIsWeb) {
                              html.window.open(url, '_blank');
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text(
                            '詳細情報',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: M3EButtonStyle.tonal,
                          size: M3EButtonSize.sm,
                          shape: M3EButtonShape.round,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          actionsWidget,
        ],
      ),
    );
  }
}
