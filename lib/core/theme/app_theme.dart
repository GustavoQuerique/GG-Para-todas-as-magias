import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: const Color(0xFF121212),
    canvasColor: const Color(0xFF121212),

    primaryColor: const Color(0xFF8B0000),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8B0000),
      secondary: Color(0xFFD4AF37),
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFD4AF37),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFEAEAEA),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Color(0xFFEAEAEA), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
      labelLarge: TextStyle(
        color: Color(0xFFD4AF37),
        fontWeight: FontWeight.w600,
      ),
    ),

    iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF8B0000),
      foregroundColor: Color(0xFFD4AF37),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: const Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37)),
      ),
      labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
    ),

    dividerColor: Colors.white10,
  );
}
