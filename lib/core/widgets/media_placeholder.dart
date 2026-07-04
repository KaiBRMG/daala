import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Token-coloured placeholder box standing in for photos/media in Phase 1
/// (no network image loading).
class MediaPlaceholder extends StatelessWidget {
  const MediaPlaceholder({
    super.key,
    this.width,
    this.height,
    this.radius = DaalaRadius.rMd,
    this.icon = Icons.image_outlined,
  });

  final double? width;
  final double? height;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DaalaColors.brandGreen50,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: DaalaColors.ink300, size: DaalaSizes.iconLg),
    );
  }
}
