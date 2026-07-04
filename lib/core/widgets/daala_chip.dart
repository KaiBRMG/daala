import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Filter chip pill (DESIGN.md §1.2): rest = `bg.secondary` +
/// `border.default` + `ink.700` text; selected = green fill + white text.
/// A [count] renders an `accent.orange.500` numeric badge; [showDot]
/// renders the active-filter orange dot.
class DaalaChip extends StatelessWidget {
  const DaalaChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.count,
    this.showDot = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          selected ? DaalaColors.brandGreen900 : DaalaColors.bgSecondary,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : const BorderSide(
                color: DaalaColors.borderDefault,
                width: DaalaSizes.borderWidth),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: DaalaTextStyles.label.copyWith(
                    color: selected
                        ? DaalaColors.onBrand
                        : DaalaColors.ink700),
              ),
              if (count != null) ...[
                const SizedBox(width: DaalaSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DaalaSpacing.s8,
                      vertical: DaalaSpacing.s2),
                  decoration: BoxDecoration(
                    color: DaalaColors.accentOrange500,
                    borderRadius:
                        BorderRadius.circular(DaalaRadius.rPill),
                  ),
                  child: Text('$count',
                      style: DaalaTextStyles.overline
                          .copyWith(color: DaalaColors.onBrand)),
                ),
              ],
              if (showDot) ...[
                const SizedBox(width: DaalaSpacing.s8),
                Container(
                  width: DaalaSpacing.s8,
                  height: DaalaSpacing.s8,
                  decoration: const BoxDecoration(
                    color: DaalaColors.accentOrange500,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
