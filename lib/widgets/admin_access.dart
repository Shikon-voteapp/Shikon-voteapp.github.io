import 'package:flutter/material.dart';

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
    final TextEditingController passwordController = TextEditingController();
    final adminPassword = 'Shikon2025';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('管理者ログイン'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  if (passwordController.text == adminPassword) {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, '/admin');
                  } else {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('パスワードが正しくありません')));
                  }
                },
                child: Text('ログイン'),
              ),
            ],
          ),
    );
  }
}
