/// Screen 3 — phone entry, the primary way into Daala.
///
/// Three things earn their place here beyond the field itself:
///
/// * **The trunk-zero fix.** South Africans type `082 345 6789`. E.164 needs
///   `+2782…`. [NationalPhoneFormatter] eats the leading zero silently, which
///   removes the single most common cause of "invalid number" on this screen.
/// * **Consent in one step.** The legal line sits under the CTA, so tapping it
///   *is* the acceptance. The timestamp is held in [signupDraftProvider] until
///   there is a uid to write it against.
/// * **OS autofill.** `AutofillHints.telephoneNumber` surfaces the device's own
///   number above the keyboard, which is faster than typing and error-proof.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../auth/legal.dart';
import '../../auth/phone_format.dart';
import '../../auth/signup_flow.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/phone_field.dart';
import '../../widgets/ui.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(signupDraftProvider);
    _controller.text = formatNationalDigits(draft.nationalDigits, draft.region);
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final region = ref.read(signupDraftProvider).region;
    ref
        .read(signupDraftProvider.notifier)
        .setNationalDigits(normaliseNationalDigits(value, region));
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _pickRegion() async {
    final selected = await showRegionPicker(
      context,
      selected: ref.read(signupDraftProvider).region,
    );
    if (selected == null || !mounted) return;
    ref.read(signupDraftProvider.notifier).setRegion(selected);
    final draft = ref.read(signupDraftProvider);
    _controller.text = formatNationalDigits(draft.nationalDigits, draft.region);
  }

  Future<void> _sendCode() async {
    final draft = ref.read(signupDraftProvider);
    if (!draft.isNumberComplete || _sending) return;

    final terms = ref.read(legalTermsProvider).value ?? LegalTerms.fallback;
    ref.read(signupDraftProvider.notifier).recordConsent(
          termsVersion: terms.termsVersion,
          privacyVersion: terms.privacyVersion,
        );

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      final verification =
          await ref.read(authRepositoryProvider).startPhoneVerification(
                e164PhoneNumber: draft.e164,
                onAutoVerified: (_) {
                  // Android silent verification. The router's session redirect
                  // takes over the moment auth state changes; nothing to do.
                },
              );
      if (!mounted) return;
      ref.read(signupDraftProvider.notifier).setVerification(verification);
      context.push('/auth/verify');
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeAuthError(error).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(signupDraftProvider);
    final terms = ref.watch(legalTermsProvider).value ?? LegalTerms.fallback;
    final canSubmit = draft.isNumberComplete;

    return AuthScaffold(
      title: 'Enter your phone number',
      subtitle:
          "We'll send you a $kOtpLength-digit verification code by SMS. "
          'Standard rates apply.',
      onBack: context.canPop() ? context.pop : null,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwButton(
            label: 'Send Code',
            loading: _sending,
            onTap: canSubmit ? _sendCode : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          ConsentLine(terms: terms),
          const SizedBox(height: AppSpacing.xs),
          GwTextAction(
            label: 'Log in with Email',
            onTap: () => context.push('/auth/email'),
          ),
        ],
      ),
      children: [
        PhoneNumberField(
          controller: _controller,
          focusNode: _focusNode,
          region: draft.region,
          onChanged: _onChanged,
          onRegionTap: _pickRegion,
          onSubmitted: canSubmit ? _sendCode : null,
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.lg),
          InlineNotice(_error!, emphasis: true),
        ],
        const SizedBox(height: AppSpacing.xl4),
        const _ReassuranceRow(),
      ],
    );
  }
}

/// Why we want the number, said once, plainly. Trust is the interface —
/// asking for a phone number without saying what it is for is exactly the
/// moment a low-trust audience abandons.
class _ReassuranceRow extends StatelessWidget {
  const _ReassuranceRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            Icons.visibility_off_rounded,
            size: 16,
            color: AppColors.green,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            'Your number stays private. Other people on Daala never see it — '
            'it only proves this account is really you.',
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}
