import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// List row primitive (DESIGN.md §1.2): min height 64, leading icon/avatar,
/// title + caption stack, optional trailing, hairline divider.
class DaalaListRow extends StatelessWidget {
  const DaalaListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.titleColor = DaalaColors.ink900,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
                minHeight: DaalaSizes.listRowMinHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: DaalaSpacing.s16,
                  vertical: DaalaSpacing.s12),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: DaalaSpacing.s12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DaalaTextStyles.title
                              .copyWith(color: titleColor),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: DaalaSpacing.s2),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DaalaTextStyles.caption
                                .copyWith(color: DaalaColors.ink500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: DaalaSpacing.s12),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(indent: DaalaSpacing.s16),
      ],
    );
  }
}

/// Leading tinted-circle icon for list rows (40, `brand.green.50` bg).
class LeadingCircleIcon extends StatelessWidget {
  const LeadingCircleIcon({
    super.key,
    required this.icon,
    this.color = DaalaColors.brandGreen900,
    this.background = DaalaColors.brandGreen50,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DaalaSizes.leadingIconCircle,
      height: DaalaSizes.leadingIconCircle,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: DaalaSizes.iconMd),
    );
  }
}

/// Shimmer skeleton for a standard list row.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s12),
      child: Row(
        children: [
          ShimmerCircle(size: DaalaSizes.leadingIconCircle),
          SizedBox(width: DaalaSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBar(height: DaalaSpacing.s16),
                SizedBox(height: DaalaSpacing.s8),
                ShimmerBar(height: DaalaSpacing.s12, widthFactor: 0.6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          color: DaalaColors.bgSecondary, shape: BoxShape.circle),
    );
  }
}

class ShimmerBar extends StatelessWidget {
  const ShimmerBar({super.key, required this.height, this.widthFactor = 1});

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: DaalaColors.bgSecondary,
          borderRadius: BorderRadius.circular(DaalaRadius.rSm),
        ),
      ),
    );
  }
}
