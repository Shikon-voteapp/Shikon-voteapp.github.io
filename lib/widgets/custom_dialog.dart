import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shikon_voteapp/screens/admin_screen.dart';
import 'package:shikon_voteapp/theme.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String content,
  VoidCallback? onPrimaryAction,
  String? primaryActionText,
  String closeButtonText = '閉じる',
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
        onPrimaryAction: onPrimaryAction,
        primaryActionText: primaryActionText,
        closeButtonText: closeButtonText,
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
                    fillColor: AppTheme.backgroundColor,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'パスワード',
                    border: OutlineInputBorder(),
                    fillColor: AppTheme.backgroundColor,
                    filled: true,
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

  const CustomDialogWidget({
    Key? key,
    required this.title,
    this.content,
    this.contentWidget,
    this.onPrimaryAction,
    this.primaryActionText,
    this.closeButtonText = '閉じる',
  }) : assert(content != null || contentWidget != null),
       super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    contentWidget ??
                        Text(
                          content!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
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
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: const Color(0xFF592C7A),
                        foregroundColor: Colors.white,
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
