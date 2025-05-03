import 'package:flutter/material.dart';
import '../platform/platform_utils.dart';

class CameraPermissionWrapper extends StatefulWidget {
  final Widget child;

  const CameraPermissionWrapper({Key? key, required this.child})
    : super(key: key);

  @override
  _CameraPermissionWrapperState createState() =>
      _CameraPermissionWrapperState();
}

class _CameraPermissionWrapperState extends State<CameraPermissionWrapper> {
  bool _permissionChecked = false;
  bool _hasPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    try {
      final permissionResult = await PlatformUtils.requestCameraPermission();

      setState(() {
        _permissionChecked = true;
        _hasPermission = permissionResult.granted;
        _errorMessage = permissionResult.errorMessage;
      });
    } catch (e) {
      setState(() {
        _permissionChecked = true;
        _hasPermission = false;
        _errorMessage = e.toString();
      });
      print('Camera permission error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return CameraPermissionLoadingScreen();
    } else if (!_hasPermission) {
      return CameraPermissionDeniedScreen(
        errorMessage: _errorMessage,
        onRetry: () {
          setState(() {
            _permissionChecked = false;
          });
          _checkCameraPermission();
        },
      );
    }

    return widget.child;
  }
}

class CameraPermissionLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'カメラ権限を確認中...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              'カメラへのアクセスを許可してください',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraPermissionDeniedScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const CameraPermissionDeniedScreen({
    Key? key,
    this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.no_photography, size: 64, color: Colors.red),
              SizedBox(height: 24),
              Text(
                'カメラへのアクセスが拒否されました',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                PlatformUtils.isWeb
                    ? 'このアプリはQRコードをスキャンするためにカメラへのアクセスが必要です。ブラウザの設定からカメラへのアクセスを許可してください。'
                    : 'このアプリはQRコードをスキャンするためにカメラへのアクセスが必要です。システム設定からカメラへのアクセスを許可してください。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              if (errorMessage != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$errorMessage',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('制限された機能で実行'),
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
