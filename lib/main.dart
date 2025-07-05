// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/scanner_screen.dart';
import 'firebase_options.dart';
import 'screens/admin_screen.dart';
import 'config/data_range_service.dart';
import 'config/student_map_init.dart';
import 'widgets/error_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/camera_permission_wrapper.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:js/js_util.dart' as js_util;
import 'dart:html' as html;

// Import navigatorKey from desktop implementation if on desktop
import 'platform/platform_utils_desktop.dart'
    if (dart.library.html) 'platform/platform_utils_web_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    if (js_util.hasProperty(html.window, "flutterReady")) {
      js_util.callMethod(html.window, "flutterReady", []);
    }
  }

  final dateRangeService = DateRangeService();
  await dateRangeService.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 学生マッピングの初期化
    final studentMappingInitializer = StudentMappingInitializer();
    await studentMappingInitializer.initializeMappings();

    runApp(MyApp(dateRangeService: dateRangeService));
  } catch (e) {
    print('Firebase初期化エラー: $e');
    runApp(MaterialApp(home: ErrorScreen(error: e.toString())));
  }
}

class MyApp extends StatelessWidget {
  final DateRangeService dateRangeService;

  const MyApp({Key? key, required this.dateRangeService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Add navigator key for app state management
      title: '紫紺祭投票アプリ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
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
