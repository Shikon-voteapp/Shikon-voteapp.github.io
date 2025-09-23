import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_dialog.dart';

class AdminAccessButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAdminLoginDialog(context),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.admin_panel_settings,
          color: Colors.grey.shade700,
          size: 20,
        ),
      ),
    );
  }

  void _showAdminLoginDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('管理者ログイン'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'メールアドレス',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'パスワード',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  await showCustomDialog(
                                    context: context,
                                    title: '入力エラー',
                                    content: 'メールアドレスとパスワードを入力してください',
                                    closeButtonText: 'OK',
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                        email: emailController.text.trim(),
                                        password: passwordController.text,
                                      );

                                  Navigator.of(context).pop();

                                  Navigator.pushNamed(context, '/admin');
                                } on FirebaseAuthException catch (e) {
                                  String message;
                                  if (e.code == 'user-not-found') {
                                    message = 'このメールアドレスに該当するユーザーが見つかりません';
                                  } else if (e.code == 'wrong-password') {
                                    message = 'パスワードが正しくありません';
                                  } else {
                                    message = 'ログインエラー: ${e.message}';
                                  }
                                  await showCustomDialog(
                                    context: context,
                                    title: 'エラー',
                                    content: message,
                                    closeButtonText: '閉じる',
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  await showCustomDialog(
                                    context: context,
                                    title: 'エラー',
                                    content: 'エラーが発生しました: $e',
                                    closeButtonText: '閉じる',
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                      child: Text('ログイン'),
                    ),
                  ],
                ),
          ),
    );
  }
}
