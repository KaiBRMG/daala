import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Flat bordered card — e0 (1 px border, no shadow), radius `rLg`,
/// padding `s16` (DESIGN.md §1.2).
class DaalaCard extends StatelessWidget {
  const DaalaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(DaalaSpacing.s16),
    this.color = DaalaColors.bgPrimary,
    this.borderColor = DaalaColors.borderDefault,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DaalaRadius.rLg),
        side: BorderSide(
            color: borderColor, width: DaalaSizes.borderWidth),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
