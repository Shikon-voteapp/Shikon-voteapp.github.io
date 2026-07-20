import 'package:flutter/material.dart';

const Color shikonPurple = Color(0xFF4A2A8A);
const Color lightPurple = Color(0xFFF3E5F5);

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimaryColor = shikonPurple;
  static const Color lightBackgroundColor = Color(0xFFF5F5F5); // 明るい灰
  static const Color lightWidgetBackgroundColor = Colors.white;
  static final Color lightAccentColor = Colors.white;

  // Dark Theme Colors
  static const Color darkPrimaryColor = lightPurple;
  static const Color darkBackgroundColor = Color(0xFF121212); // 近年の標準ダーク
  static const Color darkWidgetBackgroundColor = Color(0xFF1E1E1E);
  static final Color darkAccentColor = Colors.grey[800]!;

  static ThemeData get lightThemeData {
    final baseText = ThemeData(brightness: Brightness.light).textTheme.apply(
      fontFamily: 'SFProDisplay',
      fontFamilyFallback: const ['HiraginoSans'],
    );
    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      headlineLarge: baseText.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.3),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      primary: shikonPurple,
      onPrimary: Colors.white,
      secondary: Color(0xFF616161),
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: lightBackgroundColor,
      onSurface: Color(0xFF121212),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SFProDisplay',
      fontFamilyFallback: const ['HiraginoSans'],
      colorScheme: colorScheme,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get darkThemeData {
    final baseText = ThemeData(brightness: Brightness.dark).textTheme.apply(
      fontFamily: 'SFProDisplay',
      fontFamilyFallback: const ['HiraginoSans'],
    );
    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      displayMedium: baseText.displayMedium?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      headlineLarge: baseText.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.4),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: lightPurple,
      onPrimary: Colors.black,
      secondary: Color(0xFF9E9E9E),
      onSecondary: Colors.black,
      error: Color(0xFFCF6679),
      onError: Colors.black,
      surface: darkBackgroundColor,
      onSurface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SFProDisplay',
      fontFamilyFallback: const ['HiraginoSans'],
      colorScheme: colorScheme,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: textTheme,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.all(12),
        color: darkWidgetBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        filled: true,
        fillColor: Color(0xFF1A1A1A),
      ),
    );
  }
}
