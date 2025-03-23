import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/scanner_screen.dart';
import 'firebase_options.dart';
import 'screens/admin_screen.dart';
import 'dart:html' as html;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(VoteApp());
  } catch (e) {
    print('Firebase初期化エラー: $e');
    runApp(MaterialApp(home: ErrorScreen(error: e.toString())));
  }
}

class VoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '紫紺祭投票アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM Plex Sans JP',
        useMaterial3: false,
      ),
      home: SplashScreen(),
      routes: {
        '/scanner':
            (context) => CameraPermissionWrapper(child: ScannerScreen()),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // スプラッシュスクリーンを表示する時間（ミリ秒）
    Timer(Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CameraPermissionWrapper(child: ScannerScreen()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.deepPurple),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_vote, size: 150, color: Colors.white),
            // App logo or icon
            /*Image.asset(
              'assets/group.jpg', // Make sure to add this asset to your pubspec.yaml
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.camera_alt, size: 150, color: Colors.white);
              },
            ),*/
            SizedBox(height: 30),
            // App title
            Text(
              '紫紺祭投票アプリ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 50),
            // Loading animation
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              '読み込み中...',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Camera permission wrapper for web
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
      // For web, request camera access
      final userMedia = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': true,
        'audio': false,
      });

      if (userMedia != null) {
        userMedia.getTracks().forEach((track) => track.stop());
        setState(() {
          _permissionChecked = true;
          _hasPermission = true;
        });
      }
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
                'このアプリはQRコードをスキャンするためにカメラへのアクセスが必要です。ブラウザの設定からカメラへのアクセスを許可してください。',
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
                label: Text('再試行'),
                onPressed: onRetry,
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
                // Restart app or retry initialization
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => VoteApp()),
                );
              },
              child: Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}
