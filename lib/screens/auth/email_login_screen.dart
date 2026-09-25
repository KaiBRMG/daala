/// Screen 7 — email sign-in, for someone who can't reach their phone.
///
/// **Reworked from phase2.md's email-OTP design.** Firebase has no email OTP;
/// the mechanism is a passwordless sign-in link, so there is no code grid here.
///
/// Email is a way back *into* an account, never a way to make one. The copy
/// says so up front — "if you have an account with us, we'll send you a link" —
/// and a permanent "New to Daala?" route sends newcomers to phone signup.
///
/// The screen cannot check the address first: Firebase's email enumeration
/// protection blocks that lookup, and defeating it would let anyone test who
/// has a Daala account. So the send is unconditional and neutral, and the
/// no-account rule is enforced when the link is opened
/// ([AuthRepository.completeEmailLink]), where no account is ever created.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../auth/phone_format.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _controller.text.trim();
    if (!looksLikeEmail(email) || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref.read(pendingEmailStoreProvider).savePendingEmail(email);
      await ref.read(authRepositoryProvider).sendEmailSignInLink(email);
      if (!mounted) return;
      context.push('/auth/email-sent', extra: email);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeAuthError(error).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valid = looksLikeEmail(_controller.text);

    return AuthScaffold(
      title: 'Log in with email',
      subtitle: 'If you have an account with us, we’ll send you a link that '
          'signs you straight in. No password to remember.',
      onBack: context.canPop() ? context.pop : null,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwButton(
            label: 'Send me a link',
            loading: _sending,
            onTap: valid ? _send : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          GwTextAction(
            label: 'Log in with phone number instead',
            onTap: () => context.pop(),
          ),
        ],
      ),
      children: [
        FieldShell(
          focused: _focusNode.hasFocus,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            style: AppText.value.copyWith(fontSize: 17),
            cursorColor: AppColors.cream,
            onSubmitted: (_) => valid ? _send() : null,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'you@example.co.za',
              hintStyle: AppText.value.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.inkMuted,
              ),
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.lg),
          InlineNotice(_error!, emphasis: true),
        ],
        const SizedBox(height: AppSpacing.xl4 + AppSpacing.xs),
        // The new-user route, always present rather than surfaced by an
        // existence check. A first-time visitor who guessed wrong finds their
        // way here without us confirming who is and isn't registered. `go`,
        // not `pop`: this screen isn't always stacked on the phone page.
        GwCard(
          onTap: () => context.go('/auth/phone'),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.creamTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_rounded,
                  size: 17,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New to Daala? Create an account',
                        style: AppText.rowTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Accounts are made with your phone number',
                      style: AppText.meta.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.inkFaint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
