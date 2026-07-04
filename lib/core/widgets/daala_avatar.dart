import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Avatar — `rPill`, sizes 24/32/44/64. Phase 1 has no network images, so
/// this always renders the fallback: initials on `brand.green.50`.
class DaalaAvatar extends StatelessWidget {
  const DaalaAvatar({
    super.key,
    required this.name,
    this.size = DaalaSizes.avatarMd,
  });

  final String name;
  final double size;

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  TextStyle get _style {
    if (size >= DaalaSizes.avatarLg) return DaalaTextStyles.h3;
    if (size >= DaalaSizes.avatarMd) return DaalaTextStyles.title;
    if (size >= DaalaSizes.avatarSm) return DaalaTextStyles.label;
    return DaalaTextStyles.overline;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: DaalaColors.brandGreen50,
        shape: BoxShape.circle,
      ),
      child: Text(_initials,
          style: _style.copyWith(color: DaalaColors.brandGreen900)),
    );
  }
}
