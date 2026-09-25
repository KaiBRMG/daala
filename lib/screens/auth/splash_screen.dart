/// Screen 1 — boot.
///
/// The one screen with nothing on it but the brand: the cream wordmark alone on
/// the green ground, no cards. It lasts about a second and is never seen twice
/// in a session.
///
/// **Shutters open.** The wordmark is cut into its five glyphs, and each one
/// rolls up from behind a hidden baseline, left to right, the way stall
/// shutters go up when a market opens. The tagline follows, then the orange rule
/// draws out from its centre. If the session is still resolving after that, the
/// rule drifts slowly side to side as the "working" signal; on a normal boot
/// the router leaves before it starts.
///
/// Everything is clips and translates over the one logo asset: no Lottie or Rive
/// runtime, no extra asset bytes, one decoded image shared by all five slices.
/// Reduced motion gets the finished composition with nothing moving.
///
/// Routing is not this screen's job: `router.dart` holds the app here until the
/// session resolves, so a slow network delays the redirect, never the frame.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Entrance length. The router's splash floor (`splashFloorProvider`) is set
/// just past this so the settled composition holds for a beat before leaving.
const Duration _kEntrance = Duration(milliseconds: 860);

/// One full side-to-side pass of the waiting rule. Slow on purpose: it should
/// read as "still working", not as urgency.
const Duration _kDrift = Duration(milliseconds: 1100);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance =
      AnimationController(vsync: this, duration: _kEntrance);

  late final AnimationController _drift =
      AnimationController(vsync: this, duration: _kDrift);

  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.5, 0.82, curve: Curves.easeOut),
  );

  late final Animation<double> _ruleDraw = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.66, 1, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _ruleDrift = CurvedAnimation(
    parent: _drift,
    curve: Curves.easeInOutSine,
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward().whenComplete(() {
      // Only reached on a slow boot: the redirect normally disposes the screen
      // first. Starting from the centre (0.5) keeps the handover seamless.
      if (mounted) _drift.repeat(reverse: true, min: 0, max: 1);
    });
    _drift.value = 0.5;
  }

  @override
  void dispose() {
    _entrance.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4 * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShutterWordmark(
                progress: reduceMotion ? null : _entrance,
              ),
              const SizedBox(height: AppSpacing.xl4),
              _maybeFade(
                reduceMotion,
                _taglineFade,
                Text(
                  'Get it done. Get paid.',
                  textAlign: TextAlign.center,
                  style: AppText.value.copyWith(color: AppColors.inkBody),
                ),
              ),
              const SizedBox(height: AppSpacing.xl4 * 2),
              // A single short orange rule instead of a spinner: it is the one
              // orange element on the screen and it says "working" without
              // implying a measurable duration.
              if (reduceMotion)
                const _Rule()
              else
                _AnimatedRule(draw: _ruleDraw, drift: _ruleDrift),
            ],
          ),
        ),
      ),
    );
  }

  Widget _maybeFade(bool reduceMotion, Animation<double> animation, Widget child) =>
      reduceMotion ? child : FadeTransition(opacity: animation, child: child);
}

// ─── Wordmark ────────────────────────────────────────────────────────────────

/// Rendered size of the wordmark. The asset is 10:3; the size is fixed so
/// layout never waits on decode.
const double _kMarkWidth = 220;
const double _kMarkHeight = 66;

/// Where the glyphs sit in `daala-logo-light.png` (2000×600), as fractions of
/// the image width. Each cut falls at the midpoint of the gap between two
/// glyphs, measured from the asset's alpha: d 213–562 · a 581–913 ·
/// a 926–1257 · l 1288–1431 · a 1450–1781.
///
/// **If the logo is re-exported, re-measure these** — a stale cut slices a
/// letter in two.
const List<double> _kGlyphCuts = [0, 0.2858, 0.4598, 0.6363, 0.7203, 1];

/// The baseline, including the bowls' overshoot (y 521 of 600). Glyphs rise
/// from behind this line, so nothing below it is ever painted.
const double _kBaselineFraction = 521 / 600;

/// How far apart each glyph's rise starts, as a fraction of the entrance.
const double _kGlyphStagger = 0.075;

/// How long one glyph takes to rise, as a fraction of the entrance.
const double _kGlyphRise = 0.5;

/// The official wordmark, cream variant, straight on the ground — no plate —
/// cut into five shutters that roll up in turn.
///
/// [progress] null paints the settled wordmark (reduced motion).
class _ShutterWordmark extends StatelessWidget {
  const _ShutterWordmark({required this.progress});

  final Animation<double>? progress;

  @override
  Widget build(BuildContext context) {
    const clipHeight = _kMarkHeight * _kBaselineFraction;
    final glyphCount = _kGlyphCuts.length - 1;

    return Semantics(
      label: 'Daala',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: _kMarkWidth,
          height: _kMarkHeight,
          child: Stack(
            children: [
              for (var i = 0; i < glyphCount; i++)
                Positioned(
                  left: _kGlyphCuts[i] * _kMarkWidth,
                  width: (_kGlyphCuts[i + 1] - _kGlyphCuts[i]) * _kMarkWidth,
                  top: 0,
                  height: clipHeight,
                  child: _Shutter(
                    sliceLeft: _kGlyphCuts[i] * _kMarkWidth,
                    rise: progress == null
                        ? null
                        : CurvedAnimation(
                            parent: progress!,
                            curve: Interval(
                              i * _kGlyphStagger,
                              i * _kGlyphStagger + _kGlyphRise,
                              // Fast lift, long settle, no overshoot: a shutter
                              // meets its stop, it doesn't bounce off it.
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                    travel: clipHeight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One glyph's window onto the full wordmark, clipped at the baseline.
class _Shutter extends StatelessWidget {
  const _Shutter({
    required this.sliceLeft,
    required this.rise,
    required this.travel,
  });

  /// The slice's left edge within the wordmark; the image is shifted by it so
  /// this window shows only its own glyph.
  final double sliceLeft;

  /// 0 → hidden below the baseline, 1 → settled. Null paints it settled.
  final Animation<double>? rise;

  /// Distance the glyph travels: exactly the clip height, so at 0 it is
  /// entirely out of the window.
  final double travel;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      kLogoOnDark,
      width: _kMarkWidth,
      height: _kMarkHeight,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      filterQuality: FilterQuality.medium,
    );

    Widget glyph(double dy) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -sliceLeft,
              top: dy,
              width: _kMarkWidth,
              height: _kMarkHeight,
              child: image,
            ),
          ],
        );

    final rise = this.rise;
    return ClipRect(
      child: rise == null
          ? glyph(0)
          : AnimatedBuilder(
              animation: rise,
              builder: (_, _) => glyph((1 - rise.value) * travel),
            ),
    );
  }
}

// ─── Rule ────────────────────────────────────────────────────────────────────

const double _kRuleWidth = 44;
const double _kRuleHeight = 3;

/// How far either side of centre the waiting rule drifts.
const double _kRuleDriftReach = _kRuleWidth / 2;

class _Rule extends StatelessWidget {
  const _Rule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kRuleWidth,
      height: _kRuleHeight,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(AppRadius.status),
      ),
    );
  }
}

/// The rule draws out from its centre at the end of the entrance, then — only
/// if the screen is still up — drifts side to side until the router leaves.
class _AnimatedRule extends StatelessWidget {
  const _AnimatedRule({required this.draw, required this.drift});

  final Animation<double> draw;
  final Animation<double> drift;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Reserve the full drift width so the column never re-lays out.
      width: _kRuleWidth + _kRuleDriftReach * 2,
      height: _kRuleHeight,
      child: AnimatedBuilder(
        animation: Listenable.merge([draw, drift]),
        builder: (_, child) => Transform.translate(
          offset: Offset((drift.value - 0.5) * 2 * _kRuleDriftReach, 0),
          child: Transform.scale(
            scaleX: draw.value,
            child: child,
          ),
        ),
        child: const Center(child: _Rule()),
      ),
    );
  }
}
