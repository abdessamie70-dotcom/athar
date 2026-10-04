import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors - Spiritual & Mindful Palette
  static const Color primarySlateGreen = Color(0xFF28533D);
  static const Color primarySlateGreenLight = Color(0xFF3B7255);
  static const Color primarySlateGreenDark = Color(0xFF1B3929);

  static const Color accentGold = Color(0xFFC49F58);
  static const Color accentGoldLight = Color(0xFFDEBC7B);
  static const Color accentGoldDark = Color(0xFFA17F38);

  static const Color creamBackground = Color(0xFFF9F7F2);
  static const Color creamSurface = Color(0xFFFFFFFF);
  static const Color creamCard = Color(0xFFF4F0E8);

  static const Color darkBackground = Color(0xFF131815);
  static const Color darkSurface = Color(0xFF1C2420);
  static const Color darkCard = Color(0xFF232D28);

  static const Color textDark = Color(0xFF212824);
  static const Color textMutedDark = Color(0xFF68746E);

  static const Color textLight = Color(0xFFEDEDEA);
  static const Color textMutedLight = Color(0xFF9EABA4);

  // Category Colors
  static const Color categoryKnowledge = Color(0xFF2F667F); // Deep Ocean Blue
  static const Color categoryCharity = Color(0xFF386641);   // Evergreen
  static const Color categoryGoodDeed = Color(0xFF8F5D38);  // Warm Terracotta

  // Cost Badges
  static const Color costZero = Color(0xFF2E6F52);
  static const Color costLow = Color(0xFF967332);
  static const Color costHigh = Color(0xFF784534);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primarySlateGreen,
      scaffoldBackgroundColor: creamBackground,
      colorScheme: const ColorScheme.light(
        primary: primarySlateGreen,
        secondary: accentGold,
        surface: creamSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: creamBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primarySlateGreen),
        titleTextStyle: TextStyle(
          color: primarySlateGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: creamSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE8E4DA), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: creamSurface,
        selectedItemColor: primarySlateGreen,
        unselectedItemColor: textMutedDark,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySlateGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: creamCard,
        selectedColor: primarySlateGreen.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFDDD7CA)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: creamSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD7CA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD7CA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primarySlateGreen, width: 1.5),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primarySlateGreenLight,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primarySlateGreenLight,
        secondary: accentGoldLight,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: accentGoldLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF28362E), width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: accentGoldLight,
        unselectedItemColor: textMutedLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primarySlateGreenLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primarySlateGreenLight.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF2C3931)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C3931)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2C3931)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGoldLight, width: 1.5),
        ),
      ),
    );
  }
}
