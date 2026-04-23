import 'package:flutter/material.dart';

/// CricBid Brand Colors — derived from Logo:
/// Deep Royal Blue  #1A3A8F  (background of logo)
/// Crimson Red      #C0192C  (cricket ball)
/// Electric Cyan    #00CFFF  (glow ring)
/// Warm White       #F5F7FF  (text)
/// Amber Gold       #F5A623  (accent / CTA)

class AppColors {
  // ─── Light Mode Base ───────────────────────────────────────────────────────
  static const Color white        = Color(0xFFFFFFFF);
  static const Color offWhite     = Color(0xFFF4F6FD);
  static const Color surface      = Color(0xFFEDF0FC);
  static const Color surfaceVariant = Color(0xFFE0E5F5);
  static const Color border       = Color(0xFFCCD3EC);
  static const Color borderLight  = Color(0xFFDDE2F2);

  // ─── Dark Mode Base ────────────────────────────────────────────────────────
  static const Color darkBg            = Color(0xFF080D1E);
  static const Color darkSurface       = Color(0xFF0F1632);
  static const Color darkSurfaceVariant= Color(0xFF162045);
  static const Color darkBorder        = Color(0xFF1F2D5C);
  static const Color darkBorderLight   = Color(0xFF19244F);

  // ─── Primary Brand — Royal Blue (from logo background) ────────────────────
  static const Color primary         = Color(0xFF1A3A8F);
  static const Color primaryLight    = Color(0xFF2550C0);
  static const Color primaryDark     = Color(0xFF0F2260);
  static const Color primarySurface  = Color(0xFFE5EAF9);
  static const Color primarySurfaceDark = Color(0xFF0D1A40);

  // ─── Accent — Crimson Red (cricket ball) ──────────────────────────────────
  static const Color accent         = Color(0xFFC0192C);
  static const Color accentLight    = Color(0xFFE52239);
  static const Color accentSurface  = Color(0xFFFDE8EB);
  static const Color accentSurfaceDark = Color(0xFF3A0810);

  // ─── Electric Cyan — glow ring on logo ────────────────────────────────────
  static const Color cyan           = Color(0xFF00CFFF);
  static const Color cyanSurface    = Color(0xFFE0F9FF);

  // ─── Gold — CTA / highlights ──────────────────────────────────────────────
  static const Color gold           = Color(0xFFF5A623);
  static const Color goldLight      = Color(0xFFF7BC55);
  static const Color goldSurface    = Color(0xFFFEF3DC);

  // ─── Semantic ──────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color successDark    = Color(0xFF14532D);
  static const Color error          = Color(0xFFDC2626);
  static const Color errorSurface   = Color(0xFFFEE2E2);
  static const Color errorDark      = Color(0xFF7F1D1D);
  static const Color warning        = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color warningDark    = Color(0xFF78350F);
  static const Color info           = Color(0xFF00CFFF);
  static const Color infoSurface    = Color(0xFFE0F9FF);
  static const Color infoDark       = Color(0xFF003D4D);

  // ─── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0A1335);
  static const Color textSecondary  = Color(0xFF3D4F7C);
  static const Color textTertiary   = Color(0xFF7A8AB0);
  static const Color textDisabled   = Color(0xFFBBC4DE);

  static const Color textPrimaryDark   = Color(0xFFF0F3FF);
  static const Color textSecondaryDark = Color(0xFF9AAACE);
  static const Color textTertiaryDark  = Color(0xFF5A6E9C);
  static const Color textDisabledDark  = Color(0xFF2A3A60);

  // ─── Live / Auction Special ────────────────────────────────────────────────
  static const Color liveRed   = Color(0xFFEF4444);
  static const Color soldGreen = Color(0xFF16A34A);
  static const Color skipGray  = Color(0xFF6B7280);

  // ─── Gradient Sets ─────────────────────────────────────────────────────────
  /// Hero gradient — dark navy → bright blue (used on splash / login bg)
  static const List<Color> heroGradient = [
    Color(0xFF080D1E),
    Color(0xFF1A3A8F),
  ];

  /// Button gradient
  static const List<Color> primaryGradient = [
    Color(0xFF1A3A8F),
    Color(0xFF2550C0),
  ];

  /// Accent / badge gradient
  static const List<Color> accentGradient = [
    Color(0xFFC0192C),
    Color(0xFFE52239),
  ];

  /// Gold CTA
  static const List<Color> goldGradient = [
    Color(0xFFF5A623),
    Color(0xFFF7BC55),
  ];

  static const List<Color> darkCardGradient = [
    Color(0xFF0F1632),
    Color(0xFF162045),
  ];

  // ─── Team-color helpers ────────────────────────────────────────────────────
  /// Returns a semi-transparent border color derived from a team's theme color
  static Color teamBorder(Color teamColor) => teamColor.withOpacity(0.35);

  /// Returns a light surface color derived from a team's theme color
  static Color teamSurface(Color teamColor, {bool dark = false}) =>
      dark ? teamColor.withOpacity(0.18) : teamColor.withOpacity(0.10);
}
