/// Screen 1 — boot.
///
/// The only full-bleed brand surface in Daala. Every other screen is cream with
/// white cards (The Warm-Never-White Rule); this one is deep green edge to edge,
/// which is exactly what makes it read as a brand moment rather than a loading
/// state. It lasts under a second and is never seen twice in a session.
///
/// The animation is built from Flutter transforms over the existing logo asset
/// — no Lottie or Rive runtime, no extra asset bytes. If a produced animation
/// lands later, it drops into [_LogoMark] without touching routing.
///
/// Routing is not this screen's job: `router.dart` holds the app here until the
/// session resolves, so a slow network delays the redirect, never the frame.
library;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  late final Animation<double> _markScale = CurvedAnimation(
    parent: _controller,
    // A single settle, no bounce. DESIGN.md motion is state, not personality.
    curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _markFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.4, curve: Curves.easeOut),
  );

  late final Animation<double> _wordmarkFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
  );

  late final Animation<double> _railFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.green,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4 * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (reduceMotion)
                const _LogoMark()
              else
                FadeTransition(
                  opacity: _markFade,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1)
                        .animate(_markScale),
                    child: const _LogoMark(),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl4),
              _maybeFade(
                reduceMotion,
                _wordmarkFade,
                Text(
                  'Daala',
                  style: AppText.hero.copyWith(
                    fontSize: 34,
                    color: AppColors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _maybeFade(
                reduceMotion,
                _wordmarkFade,
                Text(
                  'Get it done. Get paid.',
                  textAlign: TextAlign.center,
                  style: AppText.value.copyWith(color: AppColors.white70),
                ),
              ),
              const SizedBox(height: AppSpacing.xl4 * 2),
              // A single short orange rule instead of a spinner: it is the one
              // orange element on the screen and it says "working" without
              // implying a measurable duration.
              _maybeFade(
                reduceMotion,
                _railFade,
                Container(
                  width: 44,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(AppRadius.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _maybeFade(bool reduceMotion, Animation<double> animation, Widget child) =>
      reduceMotion ? child : FadeTransition(opacity: animation, child: child);
}

/// The logo plate. A white rounded square keeps the mark legible whatever
/// colours it carries, and echoes the app's card language on the one screen
/// that has no cards.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 108,
      padding: const EdgeInsets.all(AppSpacing.xl3),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.tabbar),
      ),
      child: Image.asset(
        'assets/images/daala-logo.png',
        fit: BoxFit.contain,
        // Decorative: the wordmark below already names the app.
        excludeFromSemantics: true,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
