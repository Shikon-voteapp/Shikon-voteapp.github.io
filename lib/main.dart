// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/admin_screen.dart';
import 'config/data_range_service.dart';
import 'config/student_map_init.dart';
import 'widgets/error_screen.dart';
import 'screens/splash_screen.dart';

import 'theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:js/js_util.dart' as js_util;
import 'dart:html' as html;
import 'utils/version_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  // バージョン情報の初期化
  await VersionInfo.initialize();

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
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return NeumorphicApp(
          title: '紫紺祭投票アプリ',
          theme: const NeumorphicThemeData(
            baseColor: Color(0xFFF5F5F5),
            lightSource: LightSource.topLeft,
            depth: 4,
          ),
          darkTheme: const NeumorphicThemeData(
            baseColor: Color(0xff333333),
            accentColor: Colors.purple,
            lightSource: LightSource.topLeft,
            depth: 4,
            intensity: 0.28,
            shadowLightColor: Color(0x26FFFFFF),
            shadowDarkColor: Color(0xFF000000),
          ),
          materialTheme: AppTheme.lightThemeData,
          materialDarkTheme: AppTheme.darkThemeData,
          themeMode: ThemeMode.system,
          navigatorKey: navigatorKey,
          home: SplashScreen(dateRangeService: dateRangeService),
          routes: {'/admin': (context) => AdminScreen()},
        );
      },
    );
  }
}
