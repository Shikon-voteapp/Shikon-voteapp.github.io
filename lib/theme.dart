import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color shikonPurple = Color(0xFF4A2A8A);
const Color lightPurple = Color(0xFFF3E5F5);

class AppTheme {
  static const Color primaryColor = shikonPurple;
  static const Color backgroundColor = lightPurple;
  static const Color widgetBackgroundColor = Colors.white;
  static final Color accentColor = Colors.white;

  static ThemeData get themeData {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.ibmPlexSansJpTextTheme(),
      useMaterial3: true, // Recommending to use Material 3
    );
  }
}
