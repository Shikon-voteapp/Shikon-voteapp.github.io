import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/scanner_screen.dart';
import 'firebase_options.dart';
import 'screens/admin_screen.dart';
import 'dart:async';
import 'config/data_range_service.dart';
import 'screens/out_of_period_screen.dart';
import 'platform/platform_utils.dart';
import 'widgets/error_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/camera_permission_wrapper.dart';

// Import navigatorKey from desktop implementation if on desktop
import 'platform/platform_utils_desktop.dart'
    if (dart.library.html) 'platform/platform_utils_web_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dateRangeService = DateRangeService();
  await dateRangeService.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(VoteApp(dateRangeService: dateRangeService));
  } catch (e) {
    print('Firebase初期化エラー: $e');
    runApp(MaterialApp(home: ErrorScreen(error: e.toString())));
  }
}

class VoteApp extends StatelessWidget {
  final DateRangeService dateRangeService;

  const VoteApp({Key? key, required this.dateRangeService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add navigator key for app state management
      title: '紫紺祭投票アプリ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'IBM Plex Sans JP',
        useMaterial3: false,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(dateRangeService: dateRangeService),
        '/scanner':
            (context) => CameraPermissionWrapper(child: ScannerScreen()),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}
