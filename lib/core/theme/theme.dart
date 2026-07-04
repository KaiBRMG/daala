import 'package:flutter/material.dart';

import 'tokens.dart';

/// The single [ThemeData], derived entirely from tokens.dart.
ThemeData buildDaalaTheme() {
  const scheme = ColorScheme.light(
    primary: DaalaColors.brandGreen900,
    onPrimary: DaalaColors.onBrand,
    secondary: DaalaColors.accentOrange500,
    onSecondary: DaalaColors.onBrand,
    error: DaalaColors.statusDispute,
    onError: DaalaColors.onBrand,
    surface: DaalaColors.bgPrimary,
    onSurface: DaalaColors.ink900,
    outline: DaalaColors.borderDefault,
    outlineVariant: DaalaColors.borderSubtle,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: DaalaColors.bgPrimary,
    appBarTheme: const AppBarTheme(
      backgroundColor: DaalaColors.bgPrimary,
      foregroundColor: DaalaColors.ink900,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        height: 24 / 17,
        fontWeight: FontWeight.w600,
        color: DaalaColors.ink900,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DaalaColors.borderSubtle,
      thickness: DaalaSizes.borderWidth,
      space: DaalaSizes.borderWidth,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: DaalaColors.ink900,
      displayColor: DaalaColors.ink900,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: DaalaColors.brandGreen900,
      selectionColor: DaalaColors.brandGreen50,
      selectionHandleColor: DaalaColors.brandGreen900,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: DaalaColors.brandGreen900,
      inactiveTrackColor: DaalaColors.borderDefault,
      thumbColor: DaalaColors.brandGreen900,
      overlayColor: DaalaColors.brandGreen900.withValues(alpha: 0.08),
      rangeThumbShape: const RoundRangeSliderThumbShape(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(DaalaColors.bgPrimary),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? DaalaColors.brandGreen900
            : DaalaColors.borderDefault,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? DaalaColors.brandGreen900
            : DaalaColors.bgPrimary,
      ),
      checkColor: const WidgetStatePropertyAll(DaalaColors.onBrand),
      side: const BorderSide(
          color: DaalaColors.borderDefault, width: DaalaSizes.borderWidth),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DaalaColors.bgPrimary,
      modalBarrierColor: DaalaColors.overlayScrim,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DaalaRadius.rXl)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: DaalaColors.ink900,
      contentTextStyle:
          TextStyle(fontSize: 14, color: DaalaColors.bgPrimary),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
