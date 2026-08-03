/// Phone entry for the **email-first** signup, where an email sign-in link
/// created an account that has no phone number on it.
///
/// This is deliberately not the primary [PhoneLoginScreen]. That screen offers
/// "Log in with Email" as its secondary route in, which from here would be a
/// loop straight back to the state that sent the user to this screen. Same
/// field, same formatting — different exits.
///
/// Consent is captured here rather than on the email screen, because this is
/// the point where the account actually commits: "Send Code" is the acceptance,
/// exactly as it is on the phone-first path.
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

class LinkPhoneScreen extends ConsumerStatefulWidget {
  const LinkPhoneScreen({super.key});

  @override
  ConsumerState<LinkPhoneScreen> createState() => _LinkPhoneScreenState();
}

class _LinkPhoneScreenState extends ConsumerState<LinkPhoneScreen> {
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
                // Silent Play Services verification signs in with the phone
                // credential rather than linking it, which would abandon the
                // uid the email link created. The verify screen owns the link
                // step, so this path just carries on to it.
                onAutoVerified: (_) {},
              );
      if (!mounted) return;
      ref.read(signupDraftProvider.notifier).setVerification(verification);
      context.push('/auth/link-verify');
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
    final email = ref.watch(authRepositoryProvider).currentUser?.email;
    final canSubmit = draft.isNumberComplete;

    return AuthScaffold(
      title: 'Add your phone number',
      subtitle: 'Your email gets you back in, but a verified number is what '
          'lets you post, apply, and hold money on Daala.',
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
          // The only way out. Without it this screen is a dead end for anyone
          // who opened a link meant for a different address.
          GwTextAction(
            label: 'Use a different account',
            onTap: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
      children: [
        if (email != null) ...[
          _SignedInAs(email: email),
          const SizedBox(height: AppSpacing.xl4),
        ],
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

/// Names the address the link signed them in with, so nobody has to guess which
/// account they have landed in.
class _SignedInAs extends StatelessWidget {
  const _SignedInAs({required this.email});

  final String email;

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
          const Icon(
            Icons.mark_email_read_outlined,
            size: 18,
            color: AppColors.green,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppText.body,
                children: [
                  const TextSpan(text: 'Signed in as '),
                  TextSpan(
                    text: email,
                    style: AppText.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Why we want the number, said once, plainly — the same reassurance the
/// phone-first path gives, because the question it answers is the same.
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
