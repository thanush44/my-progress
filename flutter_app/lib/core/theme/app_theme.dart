import 'package:flutter/material.dart';

class AppTheme {
  // Dark Green + Light Green + White Palette
  static const Color primaryDark = Color(0xFF064E3B);
  static const Color primary = Color(0xFF047857);
  static const Color primaryMid = Color(0xFF059669);
  static const Color emerald = Color(0xFF10B981);
  static const Color mint = Color(0xFF34D399);
  static const Color lightMint = Color(0xFFA7F3D0);
  static const Color tintGreen = Color(0xFFD1FAE5);
  static const Color bgGreen = Color(0xFFF0FDF4);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color cardBg = Colors.white;

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primaryDark,
        secondary: emerald,
        surface: bgGreen,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F6F8),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryDark,
        unselectedItemColor: slateMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkThemeData {
    const darkBg = Color(0xFF08120C);
    const darkCard = Color(0xFF102016);
    const darkBorder = Color(0xFF1B3825);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMid,
        brightness: Brightness.dark,
        primary: emerald,
        secondary: mint,
        surface: const Color(0xFF0D1C12),
      ),
      scaffoldBackgroundColor: darkBg,
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF051108),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF051108),
        selectedItemColor: mint,
        unselectedItemColor: Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
