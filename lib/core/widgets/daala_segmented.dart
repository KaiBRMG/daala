import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Pill segmented control — selected segment `brand.green.900` fill +
/// white text, unselected `ink.700` (DESIGN.md §3.1).
class DaalaSegmented extends StatelessWidget {
  const DaalaSegmented({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.expanded = false,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// When true each segment shares the available width equally.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DaalaSpacing.s2),
      decoration: BoxDecoration(
        color: DaalaColors.bgSecondary,
        borderRadius: BorderRadius.circular(DaalaRadius.rPill),
        border: Border.all(
            color: DaalaColors.borderSubtle,
            width: DaalaSizes.borderWidth),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < segments.length; i++)
            expanded
                ? Expanded(child: _segment(i))
                : _segment(i),
        ],
      ),
    );
  }

  Widget _segment(int i) {
    final selected = i == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(i),
      child: AnimatedContainer(
        duration: DaalaMotion.fast,
        curve: DaalaMotion.standard,
        padding: const EdgeInsets.symmetric(
            horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s8),
        decoration: BoxDecoration(
          color: selected ? DaalaColors.brandGreen900 : Colors.transparent,
          borderRadius: BorderRadius.circular(DaalaRadius.rPill),
        ),
        alignment: Alignment.center,
        child: Text(
          segments[i],
          style: DaalaTextStyles.label.copyWith(
              color:
                  selected ? DaalaColors.onBrand : DaalaColors.ink700),
        ),
      ),
    );
  }
}
