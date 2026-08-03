/// Screen 6B — a returning user meets updated Terms.
///
/// Shown only when `users/{uid}.termsVersion` is behind `config/legal`, which
/// is why the version lives in a Firestore document rather than in the app
/// bundle: publishing new Terms must not require a store release.
///
/// The acceptance is recorded as a new immutable entry in
/// `users/{uid}/consents`, not as an overwrite — consent is evidence, and the
/// history is the point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../auth/legal.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

class TermsUpdateScreen extends ConsumerStatefulWidget {
  const TermsUpdateScreen({super.key});

  @override
  ConsumerState<TermsUpdateScreen> createState() => _TermsUpdateScreenState();
}

class _TermsUpdateScreenState extends ConsumerState<TermsUpdateScreen> {
  bool _agreed = false;
  bool _saving = false;
  String? _error;

  Future<void> _accept(LegalTerms terms) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null || !_agreed || _saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).acceptUpdatedTerms(
            uid: user.uid,
            consent: ConsentRecord(
              termsVersion: terms.termsVersion,
              privacyVersion: terms.privacyVersion,
              source: 'terms_update',
              acceptedAt: DateTime.now(),
            ),
          );
      await ref.read(sessionProvider.notifier).refresh();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = describeAuthError(error).message;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).value;
    final terms = session is NeedsTermsUpdate
        ? session.terms
        : (ref.watch(legalTermsProvider).value ?? LegalTerms.fallback);

    return AuthScaffold(
      title: 'We’ve updated our Terms',
      subtitle: 'Have a read, then agree to carry on using Daala.',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null) ...[
            InlineNotice(_error!, emphasis: true),
            const SizedBox(height: AppSpacing.lg),
          ],
          GwButton(
            label: 'I Agree',
            tone: GwButtonTone.green,
            loading: _saving,
            onTap: _agreed ? () => _accept(terms) : null,
          ),
        ],
      ),
      children: [
        GwCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.greenTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.article_rounded,
                      size: 16,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      'What’s changed',
                      style: AppText.cardTitle,
                    ),
                  ),
                  StatusPill('v${terms.termsVersion}'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                terms.changeSummary ??
                    'We’ve clarified how escrow holds your money and how '
                        'disputes are resolved. Nothing about your account or '
                        'your gigs changes.',
                style: AppText.body.copyWith(fontSize: 14, height: 1.55),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl2),
        _DocumentLink(label: 'Read the full Terms of Service', url: terms.termsUrl),
        const SizedBox(height: AppSpacing.md),
        _DocumentLink(label: 'Read the Privacy Notice', url: terms.privacyUrl),
        const SizedBox(height: AppSpacing.xl4),
        _AgreeCheck(
          checked: _agreed,
          onChanged: (value) => setState(() => _agreed = value),
        ),
      ],
    );
  }
}

class _DocumentLink extends StatelessWidget {
  const _DocumentLink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GwCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl2,
        vertical: AppSpacing.xl,
      ),
      shadow: AppShadows.soft,
      onTap: () async {
        try {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } catch (_) {
          /* No browser available; the summary above still stands. */
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppText.value.copyWith(color: AppColors.green),
            ),
          ),
          const Icon(
            Icons.open_in_new_rounded,
            size: 17,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }
}

/// The mandatory tick. Built from tokens rather than a Material `Checkbox` so
/// it matches the two-option selector's selected treatment — a green outline,
/// not a platform control dropped into a bespoke system.
class _AgreeCheck extends StatelessWidget {
  const _AgreeCheck({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: 'I agree to the updated Terms and Privacy Notice',
      child: Pressable(
        onTap: () => onChanged(!checked),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl2),
          decoration: BoxDecoration(
            color: checked ? AppColors.greenTint : AppColors.trackFill,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: checked ? AppColors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? AppColors.green : AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  boxShadow: checked ? null : AppShadows.soft,
                ),
                child: checked
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  'I’ve read and agree to the updated Terms and Privacy Notice.',
                  style: AppText.value.copyWith(
                    fontSize: 14,
                    color: checked ? AppColors.green : AppColors.ink65,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
