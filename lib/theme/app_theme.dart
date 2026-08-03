import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Daala gig marketplace — Khaki theme.
/// Values transcribed 1:1 from the reference design (cream #FAF7EC surfaces,
/// deep-green + vibrant-orange brand). Typeface is Outfit: the reference
/// mockup was set in Plus Jakarta Sans, but Outfit is the committed family.
abstract final class AppColors {
  // Surfaces
  static const Color canvas = Color(0xFFEFEDE6); // outer canvas
  static const Color screen = Color(0xFFFAF7EC); // page background (cream)
  static const Color card = Color(0xFFFFFFFF);
  static const Color placeholder = Color(0xFFEFE9D4); // khaki media blocks

  // Brand
  static const Color green = Color(0xFF003716);
  static const Color orange = Color(0xFFFF823A);

  // Brand tints
  static const Color greenTint = Color(0x18003716); // ~9% green
  static const Color greenTintStrong = Color(0x22003716);
  static const Color orangeTint = Color(0x22FF823A);

  // Ink (near-black text with alpha variants, as in the design)
  static const Color ink = Color(0xFF111111);
  static const Color ink70 = Color(0xB3000000); // rgba(0,0,0,.70)
  static const Color ink65 = Color(0xA6000000);
  static const Color ink60 = Color(0x99000000);
  static const Color ink55 = Color(0x8C000000);
  static const Color ink50 = Color(0x80000000);
  static const Color ink45 = Color(0x73000000);
  static const Color ink40 = Color(0x66000000);
  static const Color ink35 = Color(0x59000000);
  static const Color ink30 = Color(0x4D000000);
  static const Color ink15 = Color(0x26000000);

  // Structure
  static const Color divider = Color(0x0F000000); // rgba(0,0,0,.06)
  static const Color dividerStrong = Color(0x14000000); // rgba(0,0,0,.08)
  static const Color trackFill = Color(0x0D000000); // segmented track bg .05
  static const Color scrim = Color(0x66111A14); // rgba(17,26,20,.4)

  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
}

/// Spacing scale (DESIGN.md `spacing`). Screens added from Phase 2 onward use
/// these steps rather than inlining numbers; the Phase 1 screens still inline
/// theirs — see the migration note in CLAUDE.md.
abstract final class AppSpacing {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 14;
  static const double xl2 = 16;
  static const double xl3 = 18;
  static const double xl4 = 22;

  /// Standard horizontal screen gutter (matches the Phase 1 screens' 18px).
  static const double gutter = 18;
}

/// Corner radii.
abstract final class AppRadius {
  static const double card = 22;
  static const double button = 28; // 56-tall pill CTA
  static const double sheet = 28;
  static const double chip = 16;
  static const double tag = 14;
  static const double status = 10; // lifecycle status pill
  static const double segment = 18; // active segment of a toggle
  static const double track = 22; // segmented-toggle track
  static const double pill = 24; // search bar / speed-dial items
  static const double tabbar = 34;
}

/// Box shadows (soft, as used across the design).
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 10, color: Color(0x0D000000)),
  ];
  static const List<BoxShadow> soft = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 6, color: Color(0x0F000000)),
  ];
  static const List<BoxShadow> category = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 14, color: Color(0x12000000)),
  ];
  static const List<BoxShadow> tabbar = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x1F000000)),
  ];
  static const List<BoxShadow> fab = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 18, color: Color(0x66FF823A)),
  ];
  static const List<BoxShadow> greenCta = [
    BoxShadow(offset: Offset(0, 6), blurRadius: 16, color: Color(0x4D003716)),
  ];
  static const List<BoxShadow> orangeCta = [
    BoxShadow(offset: Offset(0, 6), blurRadius: 16, color: Color(0x59FF823A)),
  ];
  static const List<BoxShadow> speedItem = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 18, color: Color(0x29000000)),
  ];
}

/// Typography — Outfit throughout.
abstract final class AppText {
  static TextStyle _base(double size, FontWeight weight,
          {Color color = AppColors.ink, double? height, double? spacing}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  // Display / hero numbers
  static TextStyle hero = _base(52, FontWeight.w800, height: 1.0);
  static TextStyle money = _base(30, FontWeight.w800);

  // Screen titles
  static TextStyle screenTitleLg = _base(26, FontWeight.w800);
  static TextStyle detailTitle = _base(30, FontWeight.w800, height: 1.2);
  static TextStyle postTitle = _base(28, FontWeight.w800, height: 1.25);
  static TextStyle appBarTitle = _base(18, FontWeight.w700);

  // Sections / cards
  static TextStyle section = _base(16, FontWeight.w700);
  static TextStyle cardTitle = _base(15, FontWeight.w700);
  static TextStyle rowTitle = _base(14, FontWeight.w700);
  static TextStyle price = _base(16, FontWeight.w800, color: AppColors.green);

  // Body / meta
  static TextStyle body = _base(13, FontWeight.w500, color: AppColors.ink65, height: 1.6);
  // Readable-Muted Rule (DESIGN.md §2): muted text bottoms out at ink-55.
  static TextStyle meta = _base(12, FontWeight.w500, color: AppColors.ink55);
  static TextStyle metaStrong = _base(14, FontWeight.w600);
  static TextStyle label = _base(13, FontWeight.w700, color: AppColors.ink55);
  // Stat-card captions above a figure (`My Offers`, `Available Nearby`).
  static TextStyle caption = _base(12, FontWeight.w600, color: AppColors.ink55);

  /// Fact-row / sheet-row value text (w600/15) — DESIGN.md "Title" step.
  static TextStyle value = _base(15, FontWeight.w600);

  /// Large single-line input text (phone number, email) — sized so a typed
  /// value reads at arm's length in daylight without becoming a headline.
  static TextStyle inputValue = _base(22, FontWeight.w700);

  /// One OTP / date cell. Same 22px w800 as the split-card figure role.
  static TextStyle inputCell = _base(22, FontWeight.w800);

  // Micro
  static TextStyle overline =
      _base(13, FontWeight.w700, color: AppColors.ink55, spacing: 0.4);
  static TextStyle tabLabel = _base(10, FontWeight.w600);
  static TextStyle tag = _base(12, FontWeight.w700);
  // Lifecycle status pills (`Confirmed`, `In progress`).
  static TextStyle status = _base(11, FontWeight.w700);
}

/// Single ThemeData derived from the tokens.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.screen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.orange,
      surface: AppColors.screen,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}
