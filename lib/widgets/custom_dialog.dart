import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shikon_voteapp/screens/admin_screen.dart';
import 'package:shikon_voteapp/theme.dart';

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
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
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
          final theme = Theme.of(context);
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
                        // Check if the dialog is still mounted before calling setState
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
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
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
  }) : assert(content != null || contentWidget != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imagePath != null) ...[
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            imagePath!,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: theme.colorScheme.secondaryContainer,
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
                    contentWidget ??
                        Text(
                          content!,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                  ],
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
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      label: Text(closeButtonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                      ),
                    ),
                    if (onPrimaryAction != null && primaryActionText != null)
                      ElevatedButton(
                        onPressed: () {
                          onPrimaryAction!();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(primaryActionText!),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
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
}
