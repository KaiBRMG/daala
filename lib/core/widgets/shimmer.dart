import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Lightweight left→right gradient sweep for loading skeletons — a single
/// [ShaderMask] over plain boxes, not a per-pixel effect.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  // TODO(spec): §3 references the `slow` motion token for the sweep; a
  // 250 ms loop would read as heavy/continuous, so the sweep loops calmly.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          colors: const [
            DaalaColors.bgSecondary,
            DaalaColors.borderSubtle,
            DaalaColors.bgSecondary,
          ],
          stops: const [0.35, 0.5, 0.65],
          transform: _SlideTransform(_controller.value),
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _SlideTransform extends GradientTransform {
  const _SlideTransform(this.t);

  final double t;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * t - 1) * 1.5, 0, 0);
}

/// A skeleton block matching the silhouette of real content.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = DaalaRadius.rSm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: DaalaColors.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
