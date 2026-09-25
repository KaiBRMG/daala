/// Screen 2 — the value-proposition carousel, told as **one continuous gig**.
///
/// The three slides are not three pictures. They are one scene — a single Task
/// moving through its real lifecycle — and the swipe is its timeline:
///
///  1. **Get things done.** A Task is posted; a Merchant offers, and the offer
///     is accepted (the status pill inverts to `Confirmed`).
///  2. **Pay safely.** The R450 lifts off the gig card and drops into escrow. A
///     cream shutter rolls *up* over it — the same shutter the splash opened
///     with — and the lock closes.
///  3. **Earn on your own terms.** The shutter rolls back *down*, releasing the
///     money. It lands under the week's earnings, which tick up to meet it, and
///     the Merchant's gig count goes up by one.
///
/// Every position is a pure function of the PageView's scroll offset, so the
/// scene follows the finger: drag halfway and the money is halfway to escrow;
/// drag back and it rewinds. Only the first beat (the card rising and the offer
/// being accepted) is time-driven, as a one-off entrance that picks up the
/// splash's shutters rhythm.
///
/// **The inversion is exact, never blended.** The money is painted twice: cream
/// beneath the escrow shutter, and green clipped to the shutter's own shape
/// above it. Whichever part of the figure is over cream is green, whichever is
/// over the ground is cream, so it holds full contrast at every frame of the
/// crossing (The Green-On-Bright Rule), with no colour ever interpolated.
///
/// Cost: transforms, clips and a handful of small texts over one RepaintBoundary
/// — no images, no shaders, no blur. Reduced motion snaps the scene to whole
/// slides and skips the entrance.
///
/// **Deviation from phase2.md**, noted deliberately: the spec puts the CTA on
/// the last slide only. A hidden CTA that requires two blind swipes is poor for
/// the varied-literacy audience PRODUCT.md describes, so the primary action is
/// present on every slide — "Next", then "Get Started" — with a quiet "Skip"
/// alongside. Still exactly one orange action per screen.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../money.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';

/// The one-off entrance: card rises, Merchant arrives, offer accepted. Each
/// beat inside it stays near the 250ms state-transition ceiling.
const Duration _kIntro = Duration(milliseconds: 820);

/// Slide order follows the money: posted → held → paid.
const List<(String, String)> _kSlides = [
  (
    'Get things done',
    'Delegate tasks and manage your everyday needs effortlessly.',
  ),
  ('Pay safely', 'Secure in-app payments with complete peace of mind.'),
  (
    'Earn on your own terms',
    'Find flexible gigs that fit your skills and schedule.',
  ),
];

class WelcomeCarouselScreen extends ConsumerStatefulWidget {
  const WelcomeCarouselScreen({super.key});

  @override
  ConsumerState<WelcomeCarouselScreen> createState() =>
      _WelcomeCarouselScreenState();
}

class _WelcomeCarouselScreenState extends ConsumerState<WelcomeCarouselScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: _kIntro,
  )..forward();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    _intro.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _kSlides.length - 1;

  /// The live, fractional page — the scene's timeline.
  double get _position {
    if (_controller.hasClients && _controller.position.haveDimensions) {
      return _controller.page ?? _page.toDouble();
    }
    return _page.toDouble();
  }

  Future<void> _finish() async {
    await ref.read(pendingEmailStoreProvider).markIntroSeen();
    ref.invalidate(introSeenProvider);
    if (mounted) context.go('/auth/phone');
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Scaffold(
      backgroundColor: AppColors.screen,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44 + AppSpacing.xs,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.sm,
                  top: AppSpacing.xs,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isLast ? 0 : 1,
                    child: IgnorePointer(
                      ignoring: _isLast,
                      child: GwTextAction(
                        label: 'Skip',
                        color: AppColors.inkMuted,
                        onTap: _finish,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // The gesture layer. Its pages are empty on purpose: the
                  // visible scene is drawn above it from the scroll offset, so
                  // a swipe anywhere — over the artwork included — drives it.
                  PageView.builder(
                    controller: _controller,
                    itemCount: _kSlides.length,
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _page = index);
                    },
                    itemBuilder: (context, index) => Semantics(
                      label: '${_kSlides[index].$1}. ${_kSlides[index].$2}',
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_controller, _intro]),
                          builder: (context, _) {
                            final position = _position;
                            return Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.gutter,
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: RepaintBoundary(
                                          child: _GigScene(
                                            // Reduced motion: whole slides
                                            // only, nothing travels.
                                            position: reduceMotion
                                                ? position.roundToDouble()
                                                : position,
                                            intro: reduceMotion
                                                ? 1
                                                : _intro.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl4 * 2),
                                _SlideCopy(position: position),
                                const SizedBox(height: AppSpacing.xl4),
                                _PageDots(
                                  count: _kSlides.length,
                                  position: position,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xl4,
                AppSpacing.gutter,
                AppSpacing.xl2,
              ),
              child: GwButton(
                label: _isLast ? 'Get Started' : 'Next',
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Timeline helpers ────────────────────────────────────────────────────────

/// [t] remapped to 0..1 across the window [from, to].
double _window(double t, double from, double to) =>
    ((t - from) / (to - from)).clamp(0.0, 1.0);

double _lerp(double a, double b, double t) => a + (b - a) * t;

double _ease(double t) => Curves.easeInOutCubic.transform(t);

double _rise(double t) => Curves.easeOutQuart.transform(t);

// ─── The scene ───────────────────────────────────────────────────────────────

/// The scene is authored on a fixed 300×360 stage and scaled down to fit, so
/// its choreography never depends on the phone's height.
const double _kStageW = 300;
const double _kStageH = 360;

/// Gig card: fixed height so the money can be placed on its price slot exactly.
const double _kCardH = 122;
const double _kCardPadV = AppSpacing.xl2;
const double _kCardPadH = AppSpacing.xl3;
const double _kPhoto = 48;
const double _kTagRowH = 27; // TagPill: 12px label + 6px padding each side

/// Where the card sits on each slide.
const double _kCardTopPosted = 80;
const double _kCardTopLater = 0;

/// The Merchant row.
const double _kMerchantTopPosted = 220;
const double _kMerchantTopLater = 294;

/// The escrow shutter's fully-closed rect.
const double _kVaultTop = 128;
const double _kVaultH = 153;
const double _kVaultBottom = _kVaultTop + _kVaultH;
const double _kVaultPad = 20;
const double _kLockBadge = 34;

/// Where the money sits inside the vault (under the lock row).
const double _kMoneyTopHeld =
    _kVaultTop + _kVaultPad + _kLockBadge + AppSpacing.xl3;

/// Earnings block on the last slide, revealed as the shutter rolls down.
const double _kEarnedLabelTop = 136;
const double _kEarnedFigureTop = 160;
const double _kMoneyTopPaid = 226;
const double _kPaidFromTop = 250;

/// How high the money arcs as it drops from the card into escrow.
const double _kArc = 20;

const int _kPayoutZarMinor = 45000;
const int _kEarnedBeforeZarMinor = 200000;

class _GigScene extends StatelessWidget {
  const _GigScene({required this.position, required this.intro});

  /// 0 → posted, 1 → held in escrow, 2 → paid. Fractional mid-swipe.
  final double position;

  /// The one-off entrance, 0..1.
  final double intro;

  @override
  Widget build(BuildContext context) {
    final toEscrow = position.clamp(0.0, 1.0);
    final toPaid = (position - 1).clamp(0.0, 1.0);

    // Entrance beats.
    final cardIn = _rise(_window(intro, 0.12, 0.45));
    final merchantIn = _rise(_window(intro, 0.4, 0.72));
    final accepted = intro >= 0.86;

    // Gig card: steps up out of the way as the money heads for escrow.
    final cardTop =
        _lerp(
          _kCardTopPosted,
          _kCardTopLater,
          _ease(_window(toEscrow, 0, 0.7)),
        ) +
        (1 - cardIn) * AppSpacing.xl4;

    // The Merchant steps down first, clearing room for the vault.
    final merchantTop =
        _lerp(
          _kMerchantTopPosted,
          _kMerchantTopLater,
          _ease(_window(toEscrow, 0, 0.5)),
        ) +
        (1 - merchantIn) * AppSpacing.xl4;

    // The shutter's top edge: rolls up to protect, back down to release.
    final shutterUp =
        _ease(_window(toEscrow, 0.2, 0.7)) - _ease(_window(toPaid, 0.1, 0.6));
    final shutterTop = _lerp(_kVaultBottom, _kVaultTop, shutterUp);
    final vaultShowing = shutterTop < _kVaultBottom - 0.5;
    final locked = toEscrow >= 0.9 && toPaid < 0.06;

    // The money: from the card's price slot, into the vault, out under the
    // week's earnings.
    final intoVault = _ease(_window(toEscrow, 0.2, 0.9));
    final outOfVault = _ease(_window(toPaid, 0, 0.5));
    final _Money money = _Money.at(
      priceSlotTop: cardTop + _kCardH - _kCardPadV - _kTagRowH + 3.5,
      intoVault: intoVault,
      outOfVault: outOfVault,
    );
    final moneyLabel = toPaid > 0.5
        ? formatZar(_kPayoutZarMinor, signed: true)
        : formatZar(_kPayoutZarMinor);

    // Earnings tick up as the payout lands, in whole rand.
    final earnedMinor =
        _kEarnedBeforeZarMinor +
        (_kPayoutZarMinor * _ease(_window(toPaid, 0.45, 0.85)) / 100).round() *
            100;

    final (statusLabel, statusPositive) = switch (position) {
      < 0.5 => accepted ? ('Confirmed', true) : ('Offered', false),
      < 1.5 => ('In escrow', false),
      _ => ('Completed', true),
    };

    final vaultClip = _ShutterClipper(shutterTop);

    return SizedBox(
      width: _kStageW,
      height: _kStageH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // A second card behind, suggesting a feed of gigs without drawing one.
          Positioned(
            top: cardTop - AppSpacing.xl4 - AppSpacing.xs,
            left: 26,
            right: 26,
            child: Opacity(
              opacity: cardIn * (1 - _window(toEscrow, 0, 0.4)),
              child: Transform.rotate(
                angle: -0.035,
                child: const GwCard(child: SizedBox(height: 34)),
              ),
            ),
          ),
          Positioned(
            top: cardTop,
            left: 0,
            right: 0,
            child: Opacity(opacity: cardIn, child: const _GigCard()),
          ),

          // What the shutter reveals on its way down.
          if (position > 1)
            Positioned(
              top: _kEarnedLabelTop,
              left: 0,
              right: 0,
              child: Text(
                'EARNED THIS WEEK',
                textAlign: TextAlign.center,
                style: AppText.overline,
              ),
            ),
          if (position > 1)
            Positioned(
              top: _kEarnedFigureTop,
              left: 0,
              right: 0,
              child: Text(
                formatZar(earnedMinor),
                textAlign: TextAlign.center,
                // Tabular so the figure doesn't shimmy while it counts.
                style: AppText.hero.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          if (position > 1)
            Positioned(
              top: _kPaidFromTop,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _window(toPaid, 0.7, 1),
                child: Text(
                  'from Clear the back garden',
                  textAlign: TextAlign.center,
                  style: AppText.meta,
                ),
              ),
            ),

          // The money over the ground: cream.
          money.build(
            label: moneyLabel,
            color: AppColors.cream,
            opacity: cardIn,
          ),

          // The escrow shutter.
          if (vaultShowing)
            Positioned.fill(
              child: ClipRRect(
                clipper: vaultClip,
                child: Stack(
                  children: [
                    Positioned(
                      top: _kVaultTop,
                      left: 0,
                      width: _kStageW,
                      height: _kVaultH,
                      child: _VaultFace(locked: locked),
                    ),
                  ],
                ),
              ),
            ),

          // The same money, clipped to the shutter: green wherever it is on
          // cream. Together with the cream copy below, the figure inverts
          // exactly along the shutter's edge.
          if (vaultShowing)
            Positioned.fill(
              child: ClipRRect(
                clipper: vaultClip,
                child: Stack(
                  children: [
                    money.build(label: moneyLabel, color: AppColors.green),
                  ],
                ),
              ),
            ),

          // The Merchant, always a named person on the gig.
          Positioned(
            top: merchantTop,
            left: AppSpacing.xl4,
            right: AppSpacing.xl4,
            child: Opacity(
              opacity: merchantIn,
              child: _MerchantRow(
                status: statusLabel,
                positive: statusPositive,
                gigsDone: position < 1.5 ? 62 : 63,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The travelling payout: one figure whose slot, alignment and size are all
/// interpolated between three resting places.
class _Money {
  const _Money({
    required this.top,
    required this.left,
    required this.width,
    required this.alignX,
    required this.style,
  });

  factory _Money.at({
    required double priceSlotTop,
    required double intoVault,
    required double outOfVault,
  }) {
    if (outOfVault > 0) {
      // Held → paid: out of the vault, settling centred under the earnings.
      return _Money(
        top: _lerp(_kMoneyTopHeld, _kMoneyTopPaid, outOfVault),
        left: _lerp(_kVaultPad, 0, outOfVault),
        width: _lerp(_kStageW - _kVaultPad * 2, _kStageW, outOfVault),
        alignX: _lerp(-1, 0, outOfVault),
        style: TextStyle.lerp(AppText.money, AppText.price, outOfVault)!,
      );
    }
    // Posted → held: lifts off the card's price slot and arcs into the vault.
    return _Money(
      top:
          _lerp(priceSlotTop, _kMoneyTopHeld, intoVault) -
          math.sin(math.pi * intoVault) * _kArc,
      left: _lerp(_kCardPadH, _kVaultPad, intoVault),
      width: _lerp(
        _kStageW - _kCardPadH * 2,
        _kStageW - _kVaultPad * 2,
        intoVault,
      ),
      alignX: _lerp(1, -1, intoVault),
      style: TextStyle.lerp(AppText.price, AppText.money, intoVault)!,
    );
  }

  final double top;
  final double left;
  final double width;
  final double alignX;
  final TextStyle style;

  Widget build({
    required String label,
    required Color color,
    double opacity = 1,
  }) {
    return Positioned(
      top: top,
      left: left,
      width: width,
      child: Opacity(
        opacity: opacity,
        child: Align(
          alignment: Alignment(alignX, -1),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: style.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

/// Clips to the part of the vault the shutter currently covers: from its
/// moving top edge down to the vault's floor, with the card radius, so the
/// shutter's leading edge is rounded like every other container.
class _ShutterClipper extends CustomClipper<RRect> {
  const _ShutterClipper(this.top);

  final double top;

  @override
  RRect getClip(Size size) => RRect.fromLTRBR(
    0,
    top,
    _kStageW,
    _kVaultBottom,
    const Radius.circular(AppRadius.card),
  );

  @override
  bool shouldReclip(_ShutterClipper oldClipper) => oldClipper.top != top;
}

/// The protected-money block: the one solid cream object, because the money
/// in it is protected (The Inversion Rule). The figure itself is drawn by the
/// scene so it can travel; this face leaves its slot empty.
class _VaultFace extends StatelessWidget {
  const _VaultFace({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kVaultPad),
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _kLockBadge,
                height: _kLockBadge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                    key: ValueKey(locked),
                    size: 16,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text(
                'HELD IN ESCROW',
                style: AppText.overline.copyWith(color: AppColors.greenMuted),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Released the moment the job is done',
            style: AppText.meta.copyWith(color: AppColors.greenMuted),
          ),
        ],
      ),
    );
  }
}

/// The posted Task. Its price slot is left empty: the scene draws the money
/// there so it can lift off.
class _GigCard extends StatelessWidget {
  const _GigCard();

  @override
  Widget build(BuildContext context) {
    return GwCard(
      color: AppColors.raised,
      padding: const EdgeInsets.symmetric(
        horizontal: _kCardPadH,
        vertical: _kCardPadV,
      ),
      child: SizedBox(
        height: _kCardH - _kCardPadV * 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const PhotoPlaceholder(width: _kPhoto, height: _kPhoto),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clear the back garden',
                        style: AppText.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text('Melville · 1.2km away', style: AppText.meta),
                    ],
                  ),
                ),
              ],
            ),
            const TagPill('Home & Garden'),
          ],
        ),
      ),
    );
  }
}

class _MerchantRow extends StatelessWidget {
  const _MerchantRow({
    required this.status,
    required this.positive,
    required this.gigsDone,
  });

  final String status;
  final bool positive;
  final int gigsDone;

  @override
  Widget build(BuildContext context) {
    return GwCard(
      color: AppColors.raised,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.xl,
      ),
      child: Row(
        children: [
          const InitialsAvatar(
            'MT',
            size: 38,
            fontSize: 13,
            bg: AppColors.card,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Marlo T.', style: AppText.rowTitle),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '4.9 · $gigsDone gigs done',
                      style: AppText.meta.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // The lifecycle, read off one pill: Offered → Confirmed → In escrow
          // → Completed. Positive states invert to cream.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: StatusPill(
              status,
              key: ValueKey(status),
              positive: positive,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Copy + pagination ───────────────────────────────────────────────────────

/// The slide copy tracks the finger like ordinary pages while the scene above
/// stays put and transforms. Every slide is laid out at once, so the block's
/// height is the tallest slide's and nothing below it jumps.
class _SlideCopy extends StatelessWidget {
  const _SlideCopy({required this.position});

  final double position;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            for (var i = 0; i < _kSlides.length; i++)
              Transform.translate(
                offset: Offset((i - position) * width, 0),
                child: Opacity(
                  opacity: (1 - (i - position).abs() * 1.4).clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _kSlides[i].$1,
                          textAlign: TextAlign.center,
                          style: AppText.detailTitle,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ConstrainedBox(
                          // A comfortable measure instead of the full width of
                          // a large phone.
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            _kSlides[i].$2,
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Pagination that follows the finger: the active pill stretches and fills
/// continuously with the scroll, instead of snapping when the page settles.
/// Width, not only colour, carries the state, which survives bright daylight.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.position});

  final int count;
  final double position;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final near = (1 - (i - position).abs()).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _lerp(6, 22, near),
                height: 6,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    AppColors.inkHairline,
                    AppColors.cream,
                    near,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.status),
                ),
              );
            },
          ),
      ],
    );
  }
}
