import 'package:flutter/material.dart';

class AppTheme {
  // Paleta audaz de urgencia para rescate. Naranja vibrante para atención.
  static const Color primary = Color(0xFFEA580C); // Orange 600
  static const Color primaryLight = Color(0xFFF97316); // Orange 500
  static const Color primaryGradientEnd = Color(0xFFFB923C); // Orange 400
  static const Color accent = Color(0xFF2563EB); // Blue 600 (contraste claro)
  static const Color alertCoral = Color(0xFFDC2626); // Red 600
  static const Color successGreen = Color(0xFF16A34A); // Green 600
  static const Color infoBlue = Color(0xFF2563EB); // Blue 600

  // Fondos crudos y directos
  static const Color bgLight = Color(0xFFFDFBF7); // Off-white orgánico
  static const Color cardLight = Colors.white;
  static const Color textDark = Color(0xFF171717); // Casi negro
  static const Color textMutedLight = Color(0xFF737373); // Neutral gris

  // Fondos Oscuros con alto contraste
  static const Color bgDark = Color(0xFF171717); // Casi negro
  static const Color cardDark = Color(0xFF262626); // Neutral 800
  static const Color textLight = Color(0xFFFAFAFA);
  static const Color textMutedDark = Color(0xFFA3A3A3);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: accent,
        surface: cardLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark, size: 28),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        labelStyle: const TextStyle(color: textMutedLight, fontSize: 16, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: textMutedLight.withValues(alpha: 0.8), fontSize: 16),
        prefixIconColor: textDark,
        suffixIconColor: textDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: alertCoral, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: alertCoral, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: -0.2),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: accent,
        surface: cardDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textLight, size: 28),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: textLight,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF404040), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF262626),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        labelStyle: const TextStyle(color: textMutedDark, fontSize: 16, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: textMutedDark.withValues(alpha: 0.8), fontSize: 16),
        prefixIconColor: textLight,
        suffixIconColor: textLight,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: alertCoral, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: alertCoral, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF171717),
        selectedItemColor: primaryLight,
        unselectedItemColor: textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: -0.2),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
