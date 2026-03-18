import 'package:flutter/material.dart';

class AppTheme {
  // --- Classic Professional Palette ---
  static const Color primaryBlue = Color(0xFF1A73E8); // Trustworthy Google-style Blue
  static const Color backgroundLight = Color(0xFFF1F3F4); // Soft Grey Background
  static const Color surfaceWhite = Colors.white;
  static const Color textMain = Color(0xFF202124); // High contrast near-black
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color accentSuccess = Color(0xFF1E8E3E);
  static const Color accentWarning = Color(0xFFD93025);

  // --- Classic Decorations (Clear & Usable) ---
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: surfaceWhite,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration primaryButtonDecoration() {
    return BoxDecoration(
      color: primaryBlue,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: primaryBlue.withOpacity(0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.bold, fontSize: 16),
      prefixIcon: icon != null ? Icon(icon, color: primaryBlue) : null,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentWarning, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: false, // Using Material 2 for a more familiar "classic" look
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        elevation: 4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 32),
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 26),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 20),
        bodyLarge: TextStyle(color: textMain, fontSize: 18), // Increased for 50yr old readability
        bodyMedium: TextStyle(color: textSecondary, fontSize: 16),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
        secondary: primaryBlue,
        surface: surfaceWhite,
      ),
    );
  }

  // Legacy helper methods (redirecting to new styles to avoid breaking code)
  static BoxDecoration glossyContainer({bool isCircular = false, List<Color>? colors, Border? border}) {
    return cardDecoration().copyWith(
      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: isCircular ? null : BorderRadius.circular(12),
    );
  }

  static BoxDecoration glossButtonDecoration() {
    return primaryButtonDecoration();
  }

  static const LinearGradient aquaBackground = LinearGradient(
    colors: [backgroundLight, backgroundLight],
  );

  static const LinearGradient glossyGray = LinearGradient(
    colors: [Colors.white, Color(0xFFEEEEEE)],
  );
}
