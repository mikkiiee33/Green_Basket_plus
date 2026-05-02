// lib/core/theme/app_theme.dart
// Defines the GreenBasket+ design system: colors, typography, spacing

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class AppColors {
//   // Primary greens
//   static const Color primary = Color(0xFF2E7D32);        // Deep green
//   static const Color primaryLight = Color(0xFF4CAF50);   // Medium green
//   static const Color primaryLighter = Color(0xFF81C784); // Light green
//   static const Color primarySurface = Color(0xFFE8F5E9); // Green tint bg

//   // Accent
//   static const Color accent = Color(0xFF00BFA5);          // Teal
//   static const Color accentLight = Color(0xFFB2DFDB);

//   // Neutrals
//   static const Color textPrimary = Color(0xFF1B2631);
//   static const Color textSecondary = Color(0xFF5D6D7E);
//   static const Color textLight = Color(0xFF99A3A4);

//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color background = Color(0xFFF4F9F4);
//   static const Color cardBg = Color(0xFFFFFFFF);
//   static const Color divider = Color(0xFFECF0F1);

//   // Status colors
//   static const Color success = Color(0xFF27AE60);
//   static const Color warning = Color(0xFFF39C12);
//   static const Color error = Color(0xFFE74C3C);
//   static const Color info = Color(0xFF2980B9);

//   // Risk levels
//   static const Color lowRisk = Color(0xFF27AE60);
//   static const Color moderateRisk = Color(0xFFF39C12);
//   static const Color highRisk = Color(0xFFE74C3C);

//   // High contrast (accessibility)
//   static const Color hcBackground = Color(0xFF000000);
//   static const Color hcSurface = Color(0xFF1A1A1A);
//   static const Color hcText = Color(0xFFFFFFFF);
//   static const Color hcPrimary = Color(0xFF4CAF50);
//   static const Color hcAccent = Color(0xFF00E5CC);
// }

// class AppTheme {
//   static var background;

//   static var surface;

//   static var primary;

//   static var teal;

//   static var amber;

//   static var primaryLight;

//   static ThemeData get lightTheme => _buildTheme(false, false);
//   static ThemeData get accessibleTheme => _buildTheme(false, true);
//   static ThemeData get darkTheme => _buildTheme(true, false);

//   static ThemeData _buildTheme(bool isDark, bool isAccessible) {
//     final base = isDark || isAccessible ? _darkColors() : _lightColors();

//     final double baseFontSize = isAccessible ? 1.25 : 1.0;

//     return ThemeData(
//       useMaterial3: true,
//       colorScheme: base,
//       scaffoldBackgroundColor: isAccessible
//           ? AppColors.hcBackground
//           : (isDark ? const Color(0xFF121212) : AppColors.background),
//       textTheme: _buildTextTheme(isAccessible, baseFontSize, isDark),
//       cardTheme: CardTheme(
//         elevation: 0,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: isAccessible ? AppColors.hcSurface : AppColors.cardBg,
//         shadowColor: AppColors.primary.withOpacity(0.08),
//         margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           minimumSize: Size(double.infinity, isAccessible ? 64 : 56),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           textStyle: GoogleFonts.nunito(
//             fontSize: (isAccessible ? 18 : 16) * baseFontSize,
//             fontWeight: FontWeight.w700,
//           ),
//           elevation: 0,
//         ),
//       ),
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.primary,
//           minimumSize: Size(double.infinity, isAccessible ? 64 : 56),
//           side: const BorderSide(color: AppColors.primary, width: 1.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           textStyle: GoogleFonts.nunito(
//             fontSize: (isAccessible ? 18 : 16) * baseFontSize,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: isAccessible ? AppColors.hcSurface : AppColors.primarySurface,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: AppColors.primaryLighter.withOpacity(0.4)),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: AppColors.primary, width: 2),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: isAccessible ? 20 : 16,
//         ),
//         hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14 * baseFontSize),
//         labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14 * baseFontSize),
//       ),
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: AppColors.textLight,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: isAccessible ? AppColors.hcBackground : AppColors.background,
//         foregroundColor: isAccessible ? AppColors.hcText : AppColors.textPrimary,
//         elevation: 0,
//         titleTextStyle: GoogleFonts.nunito(
//           fontSize: (isAccessible ? 22 : 20) * baseFontSize,
//           fontWeight: FontWeight.w800,
//           color: isAccessible ? AppColors.hcText : AppColors.textPrimary,
//         ),
//         centerTitle: false,
//       ),
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.primarySurface,
//         selectedColor: AppColors.primary,
//         labelStyle: GoogleFonts.nunito(
//           fontSize: 13 * baseFontSize,
//           fontWeight: FontWeight.w600,
//         ),
//         side: BorderSide.none,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//     );
//   }

//   static ColorScheme _lightColors() => ColorScheme.fromSeed(
//         seedColor: AppColors.primary,
//         primary: AppColors.primary,
//         secondary: AppColors.accent,
//         surface: AppColors.surface,
//         background: AppColors.background,
//         onPrimary: Colors.white,
//         onSecondary: Colors.white,
//       );

//   static ColorScheme _darkColors() => ColorScheme.fromSeed(
//         seedColor: AppColors.primary,
//         brightness: Brightness.dark,
//         primary: AppColors.primaryLight,
//         secondary: AppColors.accent,
//         surface: const Color(0xFF1E1E1E),
//         background: const Color(0xFF121212),
//         onPrimary: Colors.black,
//         onSecondary: Colors.black,
//       );

//   static TextTheme _buildTextTheme(bool isAccessible, double scale, bool isDark) {
//     final color = isAccessible ? AppColors.hcText : AppColors.textPrimary;
//     final secondary = isAccessible ? AppColors.hcText.withOpacity(0.7) : AppColors.textSecondary;

//     return TextTheme(
//       displayLarge: GoogleFonts.nunito(fontSize: 57 * scale, fontWeight: FontWeight.w800, color: color),
//       displayMedium: GoogleFonts.nunito(fontSize: 45 * scale, fontWeight: FontWeight.w800, color: color),
//       displaySmall: GoogleFonts.nunito(fontSize: 36 * scale, fontWeight: FontWeight.w700, color: color),
//       headlineLarge: GoogleFonts.nunito(fontSize: 32 * scale, fontWeight: FontWeight.w700, color: color),
//       headlineMedium: GoogleFonts.nunito(fontSize: 28 * scale, fontWeight: FontWeight.w700, color: color),
//       headlineSmall: GoogleFonts.nunito(fontSize: 24 * scale, fontWeight: FontWeight.w700, color: color),
//       titleLarge: GoogleFonts.nunito(fontSize: 22 * scale, fontWeight: FontWeight.w700, color: color),
//       titleMedium: GoogleFonts.nunito(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: color),
//       titleSmall: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w600, color: color),
//       bodyLarge: GoogleFonts.nunito(fontSize: 16 * scale, fontWeight: FontWeight.w400, color: color),
//       bodyMedium: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w400, color: color),
//       bodySmall: GoogleFonts.nunito(fontSize: 12 * scale, fontWeight: FontWeight.w400, color: secondary),
//       labelLarge: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w600, color: color),
//       labelMedium: GoogleFonts.nunito(fontSize: 12 * scale, fontWeight: FontWeight.w600, color: secondary),
//       labelSmall: GoogleFonts.nunito(fontSize: 11 * scale, fontWeight: FontWeight.w500, color: secondary),
//     );
//   }
// }























// lib/core/theme/app_theme.dart
// Defines the GreenBasket+ design system: colors, typography, spacing

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary greens
  static const Color primary = Color(0xFF2E7D32);        // Deep green
  static const Color primaryLight = Color(0xFF4CAF50);   // Medium green
  static const Color primaryLighter = Color(0xFF81C784); // Light green
  static const Color primarySurface = Color(0xFFE8F5E9); // Green tint bg

  // Accent
  static const Color accent = Color(0xFF00BFA5);          // Teal
  static const Color accentLight = Color(0xFFB2DFDB);

  // Neutrals
  static const Color textPrimary = Color(0xFF1B2631);
  static const Color textSecondary = Color(0xFF5D6D7E);
  static const Color textLight = Color(0xFF99A3A4);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F9F4);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFECF0F1);

  // Status colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF2980B9);

  // Risk levels
  static const Color lowRisk = Color(0xFF27AE60);
  static const Color moderateRisk = Color(0xFFF39C12);
  static const Color highRisk = Color(0xFFE74C3C);

  // High contrast (accessibility)
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF1A1A1A);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcPrimary = Color(0xFF4CAF50);
  static const Color hcAccent = Color(0xFF00E5CC);
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(false, false);
  static ThemeData get accessibleTheme => _buildTheme(false, true);
  static ThemeData get darkTheme => _buildTheme(true, false);

  static ThemeData _buildTheme(bool isDark, bool isAccessible) {
    final base = isDark || isAccessible ? _darkColors() : _lightColors();

    final double baseFontSize = isAccessible ? 1.25 : 1.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: isAccessible
          ? AppColors.hcBackground
          : (isDark ? const Color(0xFF121212) : AppColors.background),
      textTheme: _buildTextTheme(isAccessible, baseFontSize, isDark),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isAccessible ? AppColors.hcSurface : AppColors.cardBg,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, isAccessible ? 64 : 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: (isAccessible ? 18 : 16) * baseFontSize,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, isAccessible ? 64 : 56),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: (isAccessible ? 18 : 16) * baseFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isAccessible ? AppColors.hcSurface : AppColors.primarySurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryLighter.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isAccessible ? 20 : 16,
        ),
        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14 * baseFontSize),
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14 * baseFontSize),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isAccessible ? AppColors.hcBackground : AppColors.background,
        foregroundColor: isAccessible ? AppColors.hcText : AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: (isAccessible ? 22 : 20) * baseFontSize,
          fontWeight: FontWeight.w800,
          color: isAccessible ? AppColors.hcText : AppColors.textPrimary,
        ),
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.nunito(
          fontSize: 13 * baseFontSize,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ColorScheme _lightColors() => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      );

  static ColorScheme _darkColors() => ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      );

  static TextTheme _buildTextTheme(bool isAccessible, double scale, bool isDark) {
    final color = isAccessible ? AppColors.hcText : AppColors.textPrimary;
    final secondary = isAccessible ? AppColors.hcText.withValues(alpha: 0.7) : AppColors.textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.nunito(fontSize: 57 * scale, fontWeight: FontWeight.w800, color: color),
      displayMedium: GoogleFonts.nunito(fontSize: 45 * scale, fontWeight: FontWeight.w800, color: color),
      displaySmall: GoogleFonts.nunito(fontSize: 36 * scale, fontWeight: FontWeight.w700, color: color),
      headlineLarge: GoogleFonts.nunito(fontSize: 32 * scale, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.nunito(fontSize: 28 * scale, fontWeight: FontWeight.w700, color: color),
      headlineSmall: GoogleFonts.nunito(fontSize: 24 * scale, fontWeight: FontWeight.w700, color: color),
      titleLarge: GoogleFonts.nunito(fontSize: 22 * scale, fontWeight: FontWeight.w700, color: color),
      titleMedium: GoogleFonts.nunito(fontSize: 16 * scale, fontWeight: FontWeight.w600, color: color),
      titleSmall: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w600, color: color),
      bodyLarge: GoogleFonts.nunito(fontSize: 16 * scale, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w400, color: color),
      bodySmall: GoogleFonts.nunito(fontSize: 12 * scale, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: GoogleFonts.nunito(fontSize: 14 * scale, fontWeight: FontWeight.w600, color: color),
      labelMedium: GoogleFonts.nunito(fontSize: 12 * scale, fontWeight: FontWeight.w600, color: secondary),
      labelSmall: GoogleFonts.nunito(fontSize: 11 * scale, fontWeight: FontWeight.w500, color: secondary),
    );
  }
}