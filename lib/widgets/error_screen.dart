import 'package:flutter/material.dart';
import '../config/data_range_service.dart';
import '../platform/platform_utils.dart';

class ErrorScreen extends StatelessWidget {
  final String error;

  ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 20),
            Text(
              'エラーが発生しました',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                error,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Reload the app
                PlatformUtils.reloadApp();
              },
              child: Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
