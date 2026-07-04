import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Rendered wherever a map is specified — live Google Maps is deferred to
/// Phase 6. Static token-coloured mock map with pin(s); zero network.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.height = DaalaSizes.mapBlockHeight,
    this.caption,
    this.pinCount = 1,
  });

  /// Null lets the placeholder fill its parent (map view on Home).
  final double? height;
  final String? caption;
  final int pinCount;

  static const List<Alignment> _pinSpots = [
    Alignment.center,
    Alignment(-0.5, -0.3),
    Alignment(0.55, 0.25),
    Alignment(0.2, -0.55),
    Alignment(-0.35, 0.5),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DaalaRadius.rLg),
      child: Container(
        height: height,
        color: DaalaColors.brandGreen50,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _MockStreetsPainter()),
            for (var i = 0; i < pinCount && i < _pinSpots.length; i++)
              Align(
                alignment: _pinSpots[i],
                child: const Icon(Icons.place,
                    color: DaalaColors.brandGreen900,
                    size: DaalaSizes.iconLg),
              ),
            if (caption != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(DaalaSpacing.s8),
                  child: Text(
                    caption!,
                    style: DaalaTextStyles.caption
                        .copyWith(color: DaalaColors.ink500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cheap static "streets" grid so the block reads as a map.
class _MockStreetsPainter extends CustomPainter {
  const _MockStreetsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DaalaColors.bgPrimary
      ..strokeWidth = DaalaSpacing.s2;
    const step = DaalaSpacing.s40;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
