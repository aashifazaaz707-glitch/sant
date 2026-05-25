import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PALETTE CONSTANTS (Inspiration: Allen Premium Blue & PW Teal/Indigo) ---
  static const Color primaryBlue = Color(0xFF0D47A1); // Deep Navy Blue
  static const Color accentTeal = Color(0xFF00BFA5);  // Vibrant Mint/Teal
  
  static const Color lightBg = Color(0xFFF5F7FA);     // Slate-White
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightBorder = Color(0xFFE2E8F0);  // Soft Slate Border
  
  static const Color darkBg = Color(0xFF0A0E1A);      // Deep Midnight Black-Blue
  static const Color darkSurface = Color(0xFF131A2C); // Dark Card Blue
  static const Color darkBorder = Color(0xFF1E293B);  // Dark Slate Border

  // --- LIGHT THEME DEFINITION ---
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBg,
      cardColor: lightSurface,
      useMaterial3: true,
      
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentTeal,
        surface: lightSurface,
        background: lightBg,
        error: Color(0xFFD32F2F),
      ),

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.extrabold, color: Colors.black87),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black87),
        bodyMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black54),
        labelLarge: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.5),
      ),

      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withOpacity(0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),

      buttonTheme: const ButtonThemeData(
        buttonColor: primaryBlue,
        textTheme: ButtonTextTheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
        ),
      ),
    );
  }

  // --- DARK THEME DEFINITION ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkSurface,
      useMaterial3: true,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentTeal,
        surface: darkSurface,
        background: darkBg,
        error: Color(0xFFEF5350),
      ),

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.extrabold, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white70),
        bodyMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white54),
        labelLarge: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.5),
      ),

      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentTeal, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
        ),
      ),
    );
  }
}
