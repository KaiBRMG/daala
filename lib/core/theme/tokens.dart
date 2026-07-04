import 'package:flutter/material.dart';

/// Daala design tokens — single source of truth (DESIGN.md §1.2).
/// Every colour, spacing, radius, elevation and text style in the app must
/// reference these tokens. Never hard-code a hex or magic number in a widget.

abstract final class DaalaColors {
  // Brand
  static const Color brandGreen900 = Color(0xFF003716);
  static const Color brandGreen700 = Color(0xFF0A5A2A);
  static const Color brandGreen50 = Color(0xFFE7EFE9);
  static const Color accentOrange500 = Color(0xFFFF823A);
  static const Color accentOrange600 = Color(0xFFE86F28);
  static const Color accentOrange50 = Color(0xFFFFF1E8);
  static const Color surfaceCream = Color(0xFFF5F5DC);

  // Neutrals / ink / structure
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFFAF9F5);
  static const Color ink900 = Color(0xFF14231A);
  static const Color ink700 = Color(0xFF3D4A42);
  static const Color ink500 = Color(0xFF6B7770);
  static const Color ink300 = Color(0xFFA9B2AC);
  static const Color borderSubtle = Color(0xFFEDEEEA);
  static const Color borderDefault = Color(0xFFD9DDD5);
  static const Color overlayScrim = Color.fromRGBO(20, 35, 26, 0.45);
  static const Color onBrand = Color(0xFFFFFFFF);

  // Semantic / status (fg + bg pairs — drive all status badges)
  static const Color statusOpen = Color(0xFF2B6CB0);
  static const Color statusOpenBg = Color(0xFFE9F1FA);
  static const Color statusPending = Color(0xFFB7791F);
  static const Color statusPendingBg = Color(0xFFFDF3E2);
  static const Color statusEscrow = Color(0xFF0E7C7B);
  static const Color statusEscrowBg = Color(0xFFE3F2F1);
  static const Color statusProgress = Color(0xFF3A6EA5);
  static const Color statusProgressBg = Color(0xFFEAF0F7);
  static const Color statusSuccess = Color(0xFF1E7A46);
  static const Color statusSuccessBg = Color(0xFFE7F2EC);
  static const Color statusDispute = Color(0xFFC0392B);
  static const Color statusDisputeBg = Color(0xFFFBEAE8);
  static const Color statusNeutral = Color(0xFF6B7770);
  static const Color statusNeutralBg = Color(0xFFF0F1ED);
}

/// Typography scale — system-first (Inter if bundled later). Weights 400–700.
abstract final class DaalaTextStyles {
  static const TextStyle display = TextStyle(
      fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700);
  static const TextStyle h1 =
      TextStyle(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700);
  static const TextStyle h2 =
      TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600);
  static const TextStyle h3 =
      TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600);
  static const TextStyle title =
      TextStyle(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w600);
  static const TextStyle bodyLg =
      TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);
  static const TextStyle body =
      TextStyle(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400);
  static const TextStyle label =
      TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500);
  static const TextStyle caption =
      TextStyle(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400);
  static const TextStyle overline = TextStyle(
      fontSize: 11,
      height: 16 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4);
  static const TextStyle moneyLg =
      TextStyle(fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700);
  static const TextStyle moneyMd =
      TextStyle(fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700);
}

/// Spacing — 4 pt base.
abstract final class DaalaSpacing {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  /// Screen horizontal padding.
  static const double screenH = s16;

  /// Gap between sections.
  static const double sectionGap = s24;
}

abstract final class DaalaRadius {
  static const double rSm = 8;
  static const double rMd = 12; // inputs, chips
  static const double rLg = 16; // cards
  static const double rXl = 20; // sheets, hero
  static const double rPill = 999; // primary buttons, filter chips, avatars
}

/// Elevation — default cards are e0 (flat + border), never shadowed.
abstract final class DaalaElevation {
  static const List<BoxShadow> e1 = [
    BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 2,
        color: Color.fromRGBO(20, 35, 26, 0.06)),
  ];
  static const List<BoxShadow> e2 = [
    BoxShadow(
        offset: Offset(0, 2),
        blurRadius: 8,
        color: Color.fromRGBO(20, 35, 26, 0.08)),
  ];
  static const List<BoxShadow> e3 = [
    BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 24,
        color: Color.fromRGBO(20, 35, 26, 0.12)),
  ];
}

abstract final class DaalaMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
  static const Curve standard = Cubic(0.2, 0, 0, 1);
}

abstract final class DaalaSizes {
  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double searchFieldHeight = 48;
  static const double bottomNavHeight = 64;
  static const double postFabSize = 56;
  static const double listRowMinHeight = 64;
  static const double leadingIconCircle = 40;
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 44;
  static const double avatarLg = 64;
  static const double progressTrackHeight = 4;
  static const double mapBlockHeight = 160;
  static const double galleryTile = 96;
  static const double cardThumb = 56;
  static const double emptyStateIcon = 56;
  static const double iconSm = 16; // inline meta / star glyphs
  static const double iconMd = 20; // list-row circle glyphs
  static const double iconLg = 24; // 24 px grid — nav & app-bar actions
  static const double borderWidth = 1;
  static const double borderWidthFocus = 1.5;
}
