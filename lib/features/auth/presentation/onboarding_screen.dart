import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';

class _Slide {
  const _Slide(this.icon, this.headline, this.body);

  final IconData icon;
  final String headline;
  final String body;
}

// TODO(spec): 3 value-prop slides required; exact copy unspecified.
const List<_Slide> _slides = [
  _Slide(
    Icons.checklist_outlined,
    'Get things done',
    'Post a Gig Request and receive Offers from trusted local Merchants.',
  ),
  _Slide(
    Icons.handyman_outlined,
    'Earn on your terms',
    'Post a Gig Post, offer your skills and grow your income.',
  ),
  _Slide(
    Icons.verified_user_outlined,
    'Pay safely with Escrow',
    'Funds are held securely in Escrow until the work is done.',
  ),
];

/// Onboarding carousel — 3 slides, dots, Skip/Next, final "Get started"
/// (DESIGN.md §3.13).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(DaalaSpacing.s32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: DaalaSpacing.s48 * 2,
                          height: DaalaSpacing.s48 * 2,
                          decoration: const BoxDecoration(
                            color: DaalaColors.surfaceCream,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(slide.icon,
                              size: DaalaSizes.emptyStateIcon,
                              color: DaalaColors.brandGreen900),
                        ),
                        const SizedBox(height: DaalaSpacing.s32),
                        Text(
                          slide.headline,
                          textAlign: TextAlign.center,
                          style: DaalaTextStyles.h1
                              .copyWith(color: DaalaColors.ink900),
                        ),
                        const SizedBox(height: DaalaSpacing.s12),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: DaalaTextStyles.bodyLg
                              .copyWith(color: DaalaColors.ink700),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  Container(
                    width: DaalaSpacing.s8,
                    height: DaalaSpacing.s8,
                    margin: const EdgeInsets.symmetric(
                        horizontal: DaalaSpacing.s4),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? DaalaColors.brandGreen900
                          : DaalaColors.borderDefault,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(DaalaSpacing.s16),
              child: Row(
                children: [
                  if (!isLast)
                    Expanded(
                      child: DaalaButton(
                        label: 'Skip',
                        variant: DaalaButtonVariant.tertiary,
                        onPressed: () => context.go(RoutePaths.intent),
                      ),
                    ),
                  if (!isLast) const SizedBox(width: DaalaSpacing.s12),
                  Expanded(
                    child: DaalaButton(
                      label: isLast ? 'Get started' : 'Next',
                      onPressed: () {
                        if (isLast) {
                          context.go(RoutePaths.intent);
                        } else {
                          _controller.nextPage(
                              duration: DaalaMotion.slow,
                              curve: DaalaMotion.standard);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
