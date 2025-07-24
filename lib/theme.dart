import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color shikonPurple = Color(0xFF4A2A8A);
const Color lightPurple = Color(0xFFF3E5F5);

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimaryColor = shikonPurple;
  static const Color lightBackgroundColor = lightPurple;
  static const Color lightWidgetBackgroundColor = Colors.white;
  static final Color lightAccentColor = Colors.white;

  // Dark Theme Colors
  static const Color darkPrimaryColor = shikonPurple;
  static const Color darkBackgroundColor = Color(0xFF241E30);
  static const Color darkWidgetBackgroundColor = Color(0xFF1E1E1E);
  static final Color darkAccentColor = Colors.grey[800]!;

  static ThemeData get lightThemeData {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: GoogleFonts.ibmPlexSansJpTextTheme(),
      useMaterial3: true,
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: GoogleFonts.ibmPlexSansJpTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      useMaterial3: true,
    );
  }
}
