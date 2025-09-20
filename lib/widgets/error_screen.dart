import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
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
            NeumorphicButton(
              onPressed: () {
                PlatformUtils.reloadApp();
              },
              style: const NeumorphicStyle(
                depth: 6,
                color: Colors.black,
                boxShape: NeumorphicBoxShape.stadium(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text('再試行', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
