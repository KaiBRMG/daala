import 'package:flutter/material.dart';

import '../theme/tokens.dart';

enum DaalaButtonVariant {
  /// Deep Green fill, white text — the ANZ-style confident dark button.
  /// Orange is never a default button fill.
  primary,

  /// Transparent fill, 1.5 px green border, green text.
  secondary,

  /// Green text only, 48 hit-box.
  tertiary,

  /// Dispute/Cancel only — `status.dispute` fill.
  destructive,

  /// Dispute/Cancel only — `status.dispute` text.
  destructiveText,
}

/// Bespoke token-driven button (DESIGN.md §1.2 core component styling).
class DaalaButton extends StatelessWidget {
  const DaalaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DaalaButtonVariant.primary,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final DaalaButtonVariant variant;

  /// Inline spinner — spinners are only ever button-inline, never content.
  final bool loading;
  final bool expand;

  bool get _isText =>
      variant == DaalaButtonVariant.tertiary ||
      variant == DaalaButtonVariant.destructiveText;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final Color fill;
    final Color fg;
    final Color pressed;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case DaalaButtonVariant.primary:
        fill = enabled
            ? DaalaColors.brandGreen900
            : DaalaColors.borderDefault;
        fg = enabled ? DaalaColors.onBrand : DaalaColors.ink300;
        pressed = DaalaColors.brandGreen700;
      case DaalaButtonVariant.secondary:
        fill = Colors.transparent;
        fg = enabled ? DaalaColors.brandGreen900 : DaalaColors.ink300;
        pressed = DaalaColors.brandGreen50;
        side = BorderSide(
          color: enabled
              ? DaalaColors.brandGreen900
              : DaalaColors.borderDefault,
          width: DaalaSizes.borderWidthFocus,
        );
      case DaalaButtonVariant.tertiary:
        fill = Colors.transparent;
        fg = enabled ? DaalaColors.brandGreen900 : DaalaColors.ink300;
        pressed = DaalaColors.brandGreen50;
      case DaalaButtonVariant.destructive:
        fill = enabled
            ? DaalaColors.statusDispute
            : DaalaColors.borderDefault;
        fg = enabled ? DaalaColors.onBrand : DaalaColors.ink300;
        pressed = DaalaColors.statusDispute;
      case DaalaButtonVariant.destructiveText:
        fill = Colors.transparent;
        fg = enabled ? DaalaColors.statusDispute : DaalaColors.ink300;
        pressed = DaalaColors.statusDisputeBg;
    }

    final child = loading
        ? SizedBox(
            width: DaalaSizes.iconMd,
            height: DaalaSizes.iconMd,
            child: CircularProgressIndicator(
                strokeWidth: DaalaSpacing.s2, color: fg),
          )
        : Text(label, style: DaalaTextStyles.label.copyWith(color: fg));

    final button = SizedBox(
      height: _isText ? DaalaSizes.touchTarget : DaalaSizes.buttonHeight,
      width: expand ? double.infinity : null,
      child: Material(
        color: fill,
        shape: StadiumBorder(side: side),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: enabled ? onPressed : null,
          splashColor: Colors.transparent,
          highlightColor: pressed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: DaalaSpacing.s24),
            child: Center(child: child),
          ),
        ),
      ),
    );
    return button;
  }
}
