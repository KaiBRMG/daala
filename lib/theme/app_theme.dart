import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Daala gig marketplace — "Night Market".
///
/// A dark, flat system on the brand green. The screen IS deep green (#003716);
/// depth comes only from tonal steps a shade lighter, never from shadows. Cream
/// (#F5F5DC) is the foreground and the one bright fill; orange (#ED7D31) leads
/// the single forward action. Anything sitting on a cream or orange fill is set
/// in green. See DESIGN.md.
abstract final class AppColors {
  // Brand
  static const Color green = Color(0xFF003716); // ground, and ink on bright fills
  static const Color cream = Color(0xFFF5F5DC); // foreground + bright fill
  static const Color orange = Color(0xFFED7D31); // the one forward action

  // Surfaces — tonal steps of cream mixed into green. Flat: no shadows.
  static const Color canvas = Color(0xFF002A10); // behind the screen
  static const Color screen = green; // page background
  static const Color card = Color(0xFF114424); // +1 step: cards, rows, sheets
  static const Color placeholder = Color(0xFF1B4C2C); // media stand-ins
  static const Color raised = Color(0xFF225232); // +2 step: nav, fields in cards

  // Tints (alpha over the ground, so they always read as the same hue)
  static const Color creamTint = Color(0x1AF5F5DC); // 10% — tags, icon backings
  static const Color creamTintStrong = Color(0x29F5F5DC); // 16% — category heads
  static const Color orangeTint = Color(0x2EED7D31); // 18%

  // Ink: cream text at fixed steps. The floor for text is [inkMuted], which
  // holds 4.8:1 on [card] and 6.4:1 on [screen]. Below that is non-text only.
  static const Color ink = cream;
  static const Color inkBody = Color(0xC7F5F5DC); // 78% — descriptive copy
  static const Color inkSoft = Color(0xBDF5F5DC); // 74% — secondary amounts
  static const Color inkMuted = Color(0xB0F5F5DC); // 69% — meta, labels
  static const Color inkFaint = Color(0x66F5F5DC); // 40% — non-text only
  static const Color inkHairline = Color(0x26F5F5DC); // 15% — off tracks, cells

  // On bright fills (cream / orange)
  static const Color greenMuted = Color(0xB3003716); // 70% green on cream

  // Structure
  static const Color divider = Color(0x14F5F5DC); // 8% — hairlines in cards
  static const Color dividerStrong = Color(0x1FF5F5DC); // 12% — split cards
  static const Color trackFill = Color(0x12F5F5DC); // 7% — toggle tracks
  static const Color scrim = Color(0x99001A0A); // 60% night green
}

/// The official wordmark, cream variant — for the green ground. Exported from
/// `public/logo/light.svg` (the green variant, `dark.svg`, is for light
/// backgrounds and has no use in this dark system yet).
const String kLogoOnDark = 'assets/images/daala-logo-light.png';

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

/// Corner radii. Containers are tighter than the old cushioned system; the
/// pill stays the signature for things you press or read as a label.
abstract final class AppRadius {
  static const double card = 16;
  static const double button = 28; // 56-tall pill CTA
  static const double sheet = 24;
  static const double chip = 20;
  static const double tag = 14;
  static const double status = 8; // lifecycle status pill
  static const double segment = 12; // active segment of a toggle
  static const double track = 16; // segmented-toggle track, option tiles
  static const double pill = 24; // search bar / speed-dial items
  static const double tabbar = 34;
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
  static TextStyle hero = _base(52, FontWeight.w800, height: 1.0, spacing: -1);
  static TextStyle money = _base(30, FontWeight.w800, spacing: -0.5);

  // Screen titles
  static TextStyle screenTitleLg = _base(26, FontWeight.w800, spacing: -0.3);
  static TextStyle detailTitle =
      _base(30, FontWeight.w800, height: 1.2, spacing: -0.5);
  static TextStyle postTitle =
      _base(28, FontWeight.w800, height: 1.25, spacing: -0.4);
  static TextStyle appBarTitle = _base(18, FontWeight.w700);

  // Sections / cards
  static TextStyle section = _base(16, FontWeight.w700);
  static TextStyle cardTitle = _base(15, FontWeight.w700);
  static TextStyle rowTitle = _base(14, FontWeight.w700);
  // Money is cream at the heaviest weight (The Cream Money Rule).
  static TextStyle price = _base(16, FontWeight.w800);

  // Body / meta
  static TextStyle body =
      _base(13, FontWeight.w500, color: AppColors.inkBody, height: 1.6);
  // Readable-Muted Rule (DESIGN.md §2): muted text bottoms out at inkMuted.
  static TextStyle meta = _base(12, FontWeight.w500, color: AppColors.inkMuted);
  static TextStyle metaStrong = _base(14, FontWeight.w600);
  static TextStyle label = _base(13, FontWeight.w700, color: AppColors.inkMuted);
  // Stat-card captions above a figure (`My Offers`, `Available Nearby`).
  static TextStyle caption =
      _base(12, FontWeight.w600, color: AppColors.inkMuted);

  /// Fact-row / sheet-row value text (w600/15) — DESIGN.md "Title" step.
  static TextStyle value = _base(15, FontWeight.w600);

  /// Large single-line input text (phone number, email) — sized so a typed
  /// value reads at arm's length in daylight without becoming a headline.
  static TextStyle inputValue = _base(22, FontWeight.w700);

  /// One OTP / date cell. Same 22px w800 as the split-card figure role.
  static TextStyle inputCell = _base(22, FontWeight.w800);

  // Micro
  static TextStyle overline =
      _base(13, FontWeight.w700, color: AppColors.inkMuted, spacing: 0.4);
  static TextStyle tabLabel = _base(10, FontWeight.w600);
  static TextStyle tag = _base(12, FontWeight.w700);
  // Lifecycle status pills (`Confirmed`, `In progress`).
  static TextStyle status = _base(11, FontWeight.w700);
}

/// Light status-bar and navigation-bar glyphs over the green ground.
const SystemUiOverlayStyle appOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.green,
  systemNavigationBarIconBrightness: Brightness.light,
);

/// Single ThemeData derived from the tokens. Dark, and flat by construction:
/// every Material elevation that would cast a shadow is zeroed here.
ThemeData buildAppTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.cream,
    onPrimary: AppColors.green,
    secondary: AppColors.orange,
    onSecondary: AppColors.green,
    // This system has no red; errors are sentences (DESIGN.md §5).
    error: AppColors.cream,
    onError: AppColors.green,
    surface: AppColors.screen,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.card,
    outline: AppColors.dividerStrong,
    shadow: Colors.transparent,
  );
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.screen,
    canvasColor: AppColors.screen,
    shadowColor: Colors.transparent,
  );
  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.cream,
      selectionColor: Color(0x4DED7D31), // orange 30%
      selectionHandleColor: AppColors.orange,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.screen,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: appOverlayStyle,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      elevation: 0,
      modalElevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.card,
      elevation: 0,
    ),
  );
}
