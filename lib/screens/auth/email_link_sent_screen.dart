/// Screen 7A, reworked — "check your inbox".
///
/// phase2.md specified a 4-digit email OTP screen here. Firebase Auth has no
/// email OTP, so this is the waiting state for a passwordless sign-in link
/// instead: confirm where it went, offer a resend behind a cooldown, and get
/// out of the way.
///
/// The confirmation is deliberately neutral about whether an account exists —
/// see [EmailLoginScreen].
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

const int _resendCooldownSeconds = 45;

class EmailLinkSentScreen extends ConsumerStatefulWidget {
  const EmailLinkSentScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<EmailLinkSentScreen> createState() =>
      _EmailLinkSentScreenState();
}

class _EmailLinkSentScreenState extends ConsumerState<EmailLinkSentScreen> {
  Timer? _timer;
  int _secondsLeft = _resendCooldownSeconds;
  bool _resending = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) return;
    setState(() {
      _resending = true;
      _notice = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendEmailSignInLink(widget.email);
      if (!mounted) return;
      setState(() => _notice = 'Sent again. Give it a minute to arrive.');
      _startCooldown();
    } catch (error) {
      if (!mounted) return;
      setState(() => _notice = describeAuthError(error).message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0 && !_resending;

    return AuthScaffold(
      title: 'Check your inbox',
      onBack: context.canPop() ? context.pop : null,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwTextAction(
            label: canResend
                ? 'Send the link again'
                : 'Send again in 0:${_secondsLeft.clamp(0, 59).toString().padLeft(2, '0')}',
            color: canResend ? AppColors.green : AppColors.ink55,
            onTap: canResend ? _resend : null,
          ),
          GwTextAction(
            label: 'Use a different email',
            color: AppColors.ink55,
            onTap: () => context.pop(),
          ),
        ],
      ),
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.greenTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 36,
              color: AppColors.green,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl4 + AppSpacing.sm),
        GwCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SENT TO', style: AppText.overline),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.email,
                style: AppText.value.copyWith(fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl4),
        Text(
          'If a Daala account uses this address, a sign-in link is on its way. '
          'Open it on this phone and you’ll be signed straight in.',
          style: AppText.body.copyWith(fontSize: 14, height: 1.55),
        ),
        const SizedBox(height: AppSpacing.xl2),
        Text(
          'Nothing after a few minutes? Check your spam folder, and make sure '
          'the address is spelled right.',
          style: AppText.meta.copyWith(height: 1.5),
        ),
        if (_notice != null) ...[
          const SizedBox(height: AppSpacing.xl2),
          InlineNotice(_notice!, emphasis: true),
        ],
      ],
    );
  }
}
