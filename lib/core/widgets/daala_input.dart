import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Bespoke token-driven input (DESIGN.md §1.2): `bg.secondary` fill, 1 px
/// border, static top label, focus → 1.5 px green, error → 1.5 px dispute.
class DaalaInput extends StatelessWidget {
  const DaalaInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.helperText,
    this.prefixText,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.textInputAction,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.textStyle,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final String? prefixText;
  final bool obscureText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = textStyle ??
        DaalaTextStyles.body.copyWith(color: DaalaColors.ink900);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!,
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500)),
          const SizedBox(height: DaalaSpacing.s4),
        ],
        TextField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textInputAction: textInputAction,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          style: style,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: style.copyWith(color: DaalaColors.ink300),
            filled: true,
            fillColor: DaalaColors.bgSecondary,
            prefixText: prefixText,
            prefixStyle: style,
            suffixIcon: suffix,
            helperText: helperText,
            helperStyle: DaalaTextStyles.caption
                .copyWith(color: DaalaColors.ink500),
            errorText: errorText,
            errorStyle: DaalaTextStyles.caption
                .copyWith(color: DaalaColors.statusDispute),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DaalaRadius.rMd),
              borderSide: const BorderSide(
                  color: DaalaColors.borderDefault,
                  width: DaalaSizes.borderWidth),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DaalaRadius.rMd),
              borderSide: const BorderSide(
                  color: DaalaColors.brandGreen900,
                  width: DaalaSizes.borderWidthFocus),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DaalaRadius.rMd),
              borderSide: const BorderSide(
                  color: DaalaColors.statusDispute,
                  width: DaalaSizes.borderWidthFocus),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DaalaRadius.rMd),
              borderSide: const BorderSide(
                  color: DaalaColors.statusDispute,
                  width: DaalaSizes.borderWidthFocus),
            ),
          ),
        ),
      ],
    );
  }
}
