/// Screen 7 — email sign-in, for someone who can't reach their phone.
///
/// **Reworked from phase2.md's email-OTP design.** Firebase has no email OTP;
/// the mechanism is a passwordless sign-in link, so there is no code grid here.
///
/// It also drops the spec's "does this email exist?" branch. Firebase's email
/// enumeration protection blocks that lookup by default, and defeating it would
/// hand anyone a way to test whether a given address has a Daala account. The
/// screen sends the link either way and says so neutrally — with a permanent
/// route into phone signup, so a genuinely new user is never dead-ended.
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
      subtitle: 'Enter the email on your Daala account and we’ll send you a '
          'link that signs you straight in. No password to remember.',
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
            cursorColor: AppColors.green,
            onSubmitted: (_) => valid ? _send() : null,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: 'you@example.co.za',
              hintStyle: AppText.value.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColors.ink55,
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
        // way here without us confirming who is and isn't registered.
        GwCard(
          shadow: AppShadows.soft,
          onTap: () => context.pop(),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.greenTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_rounded,
                  size: 17,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New to Daala?', style: AppText.rowTitle),
                    const SizedBox(height: 2),
                    Text(
                      'Create your account with a phone number',
                      style: AppText.meta.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.ink40,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
