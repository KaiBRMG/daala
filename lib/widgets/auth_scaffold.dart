/// Shared chrome for every Phase 2 auth screen.
///
/// One layout so the flow reads as a single journey: cream canvas, a round back
/// button top-left, a large left-aligned headline, and a footer that rises with
/// the keyboard instead of hiding behind it. Content scrolls; the CTA never
/// scrolls away.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/legal.dart';
import '../theme/app_theme.dart';
import 'ui.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
    this.onBack,
    this.progress,
    this.trailing,
  });

  /// The page headline. Set at the 26px screen-title step so it stays one line
  /// on a 320dp screen.
  final String title;
  final String? subtitle;

  /// Scrolling body content.
  final List<Widget> children;

  /// Pinned to the bottom, above the keyboard and inside the safe area.
  final Widget? footer;

  /// Omit to hide the back button (the first screen in a flow).
  final VoidCallback? onBack;

  /// 0..1 progress rail shown under the header, for multi-step flows.
  final double? progress;

  /// Optional control opposite the back button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      // Lets the footer ride the keyboard rather than sitting behind it.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onBack != null || trailing != null || progress != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.xs,
                  AppSpacing.gutter,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          if (onBack != null)
                            RoundIconButton(
                              icon: Icons.arrow_back_ios_new,
                              iconSize: 16,
                              semanticLabel: 'Go back',
                              onTap: onBack,
                            ),
                          const Spacer(),
                          ?trailing,
                        ],
                      ),
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: AppSpacing.xl2),
                      ProgressRail(progress: progress!),
                    ],
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.xl4,
                  AppSpacing.gutter,
                  AppSpacing.xl4,
                ),
                children: [
                  Text(
                    title,
                    style: AppText.screenTitleLg,
                    textAlign: TextAlign.start,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(subtitle!, style: AppText.body),
                  ],
                  const SizedBox(height: AppSpacing.xl4 + AppSpacing.md),
                  ...children,
                ],
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.md,
                  AppSpacing.gutter,
                  AppSpacing.xl2,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Consent, sat directly under a CTA: tapping that CTA *is* the acceptance, and
/// both documents are one tap away in the system browser.
///
/// Shared because consent is captured at whichever screen first commits the
/// account — the phone login for a phone-first signup, the link-phone screen for
/// an email-first one — and the wording of a legal acceptance must not differ
/// between the two.
///
/// Stateful because [TapGestureRecognizer] must be disposed; building
/// recognizers inside a stateless `build` leaks one per frame.
class ConsentLine extends StatefulWidget {
  const ConsentLine({super.key, required this.terms});

  final LegalTerms terms;

  @override
  State<ConsentLine> createState() => _ConsentLineState();
}

class _ConsentLineState extends State<ConsentLine> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => _open(widget.terms.termsUrl);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => _open(widget.terms.privacyUrl);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    // Swallows failure rather than throwing: no browser on the device must
    // never break the sign-in screen.
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      /* ignored — the CTA above still works */
    }
  }

  @override
  Widget build(BuildContext context) {
    final linkStyle = AppText.meta.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.green,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.green,
    );

    return Text.rich(
      TextSpan(
        style: AppText.meta.copyWith(height: 1.5),
        children: [
          const TextSpan(text: 'By continuing, you agree to Daala’s '),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer: _termsTap,
          ),
          const TextSpan(text: ' and acknowledge our '),
          TextSpan(
            text: 'Privacy Notice',
            style: linkStyle,
            recognizer: _privacyTap,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// A white field card: a w700/13 ink-55 label above a 22-radius white card that
/// holds the control. The system's picker-first field row (DESIGN.md §5),
/// adapted to take a live input instead of a static value.
class FieldShell extends StatelessWidget {
  const FieldShell({
    super.key,
    required this.child,
    this.label,
    this.focused = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl2,
      vertical: AppSpacing.lg,
    ),
  });

  final Widget child;
  final String? label;

  /// Draws the 2px green focus ring. Always visible when focused — DESIGN.md
  /// forbids suppressing it.
  final bool focused;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label),
          const SizedBox(height: AppSpacing.sm),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.card,
            // Always a 2px border, transparent when unfocused, so gaining focus
            // never nudges the layout by 4px.
            border: Border.all(
              color: focused ? AppColors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}
