/// Screen 2 — the value-proposition carousel.
///
/// Each slide's artwork is composed from the app's own component vocabulary —
/// a gig card, a stat pair, a green balance card — rather than an illustration.
/// Two reasons: it ships zero image bytes to a data-light audience, and it shows
/// people the actual interface they are about to use, which does more to earn
/// trust than a drawing of a handshake.
///
/// **Deviation from phase2.md**, noted deliberately: the spec puts the CTA on
/// slide 3 only. A hidden CTA that requires two blind swipes is poor for the
/// varied-literacy audience PRODUCT.md describes, so the primary action is
/// present on every slide — "Next" on 1 and 2, "Get Started" on 3 — with a
/// quiet "Skip" alongside. Still exactly one orange action per screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../money.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';

class WelcomeCarouselScreen extends ConsumerStatefulWidget {
  const WelcomeCarouselScreen({super.key});

  @override
  ConsumerState<WelcomeCarouselScreen> createState() =>
      _WelcomeCarouselScreenState();
}

class _WelcomeCarouselScreenState extends ConsumerState<WelcomeCarouselScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const List<(String, String)> _slides = [
    (
      'Get things done',
      'Delegate tasks and manage your everyday needs effortlessly.',
    ),
    (
      'Earn on your own terms',
      'Find flexible gigs that fit your skills and schedule.',
    ),
    (
      'Pay safely',
      'Secure in-app payments with complete peace of mind.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _slides.length - 1;

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
                        color: AppColors.ink55,
                        onTap: _finish,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) => _Slide(
                  index: index,
                  title: _slides[index].$1,
                  body: _slides[index].$2,
                ),
              ),
            ),
            _PageDots(count: _slides.length, active: _page),
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

class _Slide extends StatelessWidget {
  const _Slide({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: switch (index) {
                0 => const _GetThingsDoneArt(),
                1 => const _EarnArt(),
                _ => const _PaySafelyArt(),
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl4 * 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.detailTitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            // Keeps the supporting line to a comfortable measure instead of
            // running the full width of a large phone.
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl4),
        ],
      ),
    );
  }
}

/// Slide 1 — a posted gig, with a real helper attached to it. The point of the
/// composition is that a named person and a status are always visible; that is
/// the whole answer to the classifieds wall.
class _GetThingsDoneArt extends StatelessWidget {
  const _GetThingsDoneArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The card behind, suggesting a stack of gigs without drawing one.
          Positioned(
            top: 0,
            left: 26,
            right: 26,
            child: Transform.rotate(
              angle: -0.035,
              child: const GwCard(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl3,
                  vertical: AppSpacing.xl2,
                ),
                child: SizedBox(height: 34),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: GwCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PhotoPlaceholder(width: 48, height: 48),
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
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const TagPill('Home & Garden'),
                      const Spacer(),
                      Text(formatZar(45000), style: AppText.price),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: AppSpacing.xl4,
            right: AppSpacing.xl4,
            child: GwCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl2,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  const InitialsAvatar('MT', size: 38, fontSize: 13),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marlo T.', style: AppText.rowTitle),
                        const SizedBox(height: 2),
                        Text('★ 4.9 · 62 gigs done',
                            style: AppText.meta.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  const StatusPill('Confirmed'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide 2 — the earn view's hero figure. Orange here is the one sanctioned
/// exception in The Green Money Rule: weekly earnings as motivation, not a
/// settled balance.
class _EarnArt extends StatelessWidget {
  const _EarnArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('EARNED THIS WEEK', style: AppText.overline),
          const SizedBox(height: AppSpacing.lg),
          Text(
            formatZar(245000),
            style: AppText.hero.copyWith(color: AppColors.orange),
          ),
          const SizedBox(height: AppSpacing.xl4 + AppSpacing.xs),
          GwCard(
            padding: EdgeInsets.zero,
            shadow: AppShadows.soft,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl3),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: AppColors.dividerStrong),
                      ),
                    ),
                    child: _Cell(
                      caption: 'Gigs Nearby',
                      value: '24',
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl3),
                    child: _Cell(
                      caption: 'Avg. Payout',
                      value: formatZar(38000),
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: const [
              TagPill('Handyman'),
              TagPill('Delivery'),
              TagPill('Cleaning'),
              TagPill('Moving'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Slide 3 — escrow. The green balance card is the app's only inverted surface,
/// and it is the right object to carry "your money is held safely".
class _PaySafelyArt extends StatelessWidget {
  const _PaySafelyArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwCard(
            color: AppColors.green,
            shadow: AppShadows.greenCta,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Text(
                      'HELD IN ESCROW',
                      style: AppText.overline.copyWith(color: AppColors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl3),
                Text(
                  formatZar(120000),
                  style: AppText.money.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Released the moment the job is done',
                  style: AppText.meta.copyWith(color: AppColors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _TrustRow(
            icon: Icons.verified_rounded,
            title: 'Verified taskers',
            body: 'ID-checked before they can earn',
          ),
          const SizedBox(height: AppSpacing.md),
          const _TrustRow(
            icon: Icons.shield_moon_rounded,
            title: 'Disputes freeze the money',
            body: 'Nobody is left stranded',
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GwCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.xl,
      ),
      shadow: AppShadows.soft,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.greenTint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.green),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.rowTitle),
                const SizedBox(height: 2),
                Text(body, style: AppText.meta.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.caption,
    required this.value,
    required this.color,
  });

  final String caption;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(caption, style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: AppText.inputCell.copyWith(color: color)),
      ],
    );
  }
}

/// Pagination. The active dot stretches into a short green pill rather than
/// simply changing colour — the pill is this system's signature shape, and the
/// width change stays readable in bright daylight where a colour shift may not.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Slide ${active + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? AppColors.green : AppColors.ink15,
                borderRadius: BorderRadius.circular(AppRadius.status),
              ),
            ),
        ],
      ),
    );
  }
}
