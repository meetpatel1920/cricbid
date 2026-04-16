import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Mode Base ───────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF2F4F7);
  static const Color surfaceVariant = Color(0xFFE9ECF0);
  static const Color border = Color(0xFFDDE1E7);
  static const Color borderLight = Color(0xFFEEF1F5);

  // ─── Dark Mode Base ────────────────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceVariant = Color(0xFF242837);
  static const Color darkBorder = Color(0xFF2E3347);
  static const Color darkBorderLight = Color(0xFF252838);

  // ─── Primary Brand ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A6B3C);       // Cricket green
  static const Color primaryLight = Color(0xFF2D8C54);
  static const Color primaryDark = Color(0xFF124D2B);
  static const Color primarySurface = Color(0xFFE8F5EE);
  static const Color primarySurfaceDark = Color(0xFF112B1C);

  // ─── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);        // Gold/amber for auction
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentSurface = Color(0xFFFFF8E7);
  static const Color accentSurfaceDark = Color(0xFF2D2410);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSurface = Color(0xFFDBEAFE);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  static const Color textPrimaryDark = Color(0xFFF1F3F7);
  static const Color textSecondaryDark = Color(0xFFADB5BD);
  static const Color textTertiaryDark = Color(0xFF6C757D);
  static const Color textDisabledDark = Color(0xFF3D4451);

  // ─── Live / Auction Special ────────────────────────────────────────────────
  static const Color liveRed = Color(0xFFEF4444);
  static const Color soldGreen = Color(0xFF16A34A);
  static const Color skipGray = Color(0xFF6B7280);

  // ─── Gradient Sets ─────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF1A6B3C),
    Color(0xFF2D8C54),
  ];
  static const List<Color> accentGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBBF24),
  ];
  static const List<Color> darkCardGradient = [
    Color(0xFF1A1D27),
    Color(0xFF242837),
  ];

  // ─── Team Theme Helpers ────────────────────────────────────────────────────
  /// Given a team hex color, generate a surface color for light mode
  static Color teamSurface(Color teamColor, {bool dark = false}) {
    if (dark) {
      return teamColor.withOpacity(0.15);
    }
    return teamColor.withOpacity(0.08);
  }

  static Color teamBorder(Color teamColor) => teamColor.withOpacity(0.3);
  static Color teamText(Color teamColor) => teamColor;
}
