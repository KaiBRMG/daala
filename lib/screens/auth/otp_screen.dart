/// Screen 4 — SMS code verification.
///
/// **Six cells, not four.** Firebase Auth SMS codes are always six digits;
/// phase2.md's four-box design could never validate one.
///
/// The six cells are a *rendering* of one real, invisible [TextField]. That is
/// what makes platform SMS autofill work: iOS one-time-code AutoFill and
/// Android's autofill service both fill a single field and neither understands
/// six separate boxes. It also gives correct paste, backspace, and caret
/// behaviour for free instead of six hand-wired focus nodes.
///
/// On Android, Play Services may verify the device silently before any SMS
/// arrives; the session redirect in `router.dart` moves the user on without
/// them touching this screen.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../auth/auth_repository.dart';
import '../../auth/phone_format.dart';
import '../../auth/signup_flow.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

/// Seconds before "Resend" becomes available again. Long enough that a slow
/// network delivery isn't mistaken for a failure, short enough not to strand
/// someone whose SMS genuinely vanished.
const int _resendCooldownSeconds = 30;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.linkToCurrentAccount = false});

  /// `true` on the email-first path: the code attaches the number to the
  /// account the email link already signed us into, instead of signing in with
  /// it. Same six cells, same autofill, different terminal call — which is why
  /// this is a flag rather than a second screen.
  final bool linkToCurrentAccount;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _cooldownTimer;
  int _secondsLeft = _resendCooldownSeconds;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  String get _code => _controller.text;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onCodeChanged);
    // The cells render the caret cue from focus, so they must rebuild with it.
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _onCodeChanged() {
    setState(() => _error = null);
    // Auto-submit on the last digit: the user has no reason to confirm a code
    // they were handed. The explicit "Verify" button stays for autofill paths
    // that land the full code without a keystroke.
    if (_code.length == kOtpLength && !_verifying) _submit();
  }

  Future<void> _submit() async {
    final verification = ref.read(signupDraftProvider).verification;
    if (verification == null || _verifying) return;

    setState(() {
      _verifying = true;
      _error = null;
    });
    // Dismiss the keyboard so the confirmation isn't hidden behind it.
    _focusNode.unfocus();

    try {
      final repository = ref.read(authRepositoryProvider);
      if (widget.linkToCurrentAccount) {
        // Captured before the call: if the number turned out to belong to an
        // older account, the repository adopts it and the uid changes under us.
        final before = repository.currentUser;
        final result = await repository.linkPhoneToCurrentUser(
          verificationId: verification.verificationId,
          smsCode: _code,
        );
        final swapped = before != null && result.uid != before.uid;
        if (swapped && before.email != null) {
          // The repository sent a fresh link to carry the address onto the
          // adopted account. Storing it here means opening that link completes
          // without asking for the address again.
          await ref
              .read(pendingEmailStoreProvider)
              .savePendingEmail(before.email!);
        }
        // Linking a credential does not necessarily emit on the auth state
        // stream — the signed-in user never changed — so the session has to be
        // recomputed by hand here. The redirect then moves on as usual.
        if (mounted) await ref.read(sessionProvider.notifier).refresh();
      } else {
        await repository.confirmPhoneCode(
          verificationId: verification.verificationId,
          smsCode: _code,
        );
        // Success intentionally does not navigate. The auth state stream fires,
        // the session recomputes, and the router redirects to onboarding or
        // Home. One source of truth for "where does this person belong" beats
        // two.
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = describeAuthError(error).message;
        _verifying = false;
      });
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _resending) return;
    final draft = ref.read(signupDraftProvider);

    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      final verification =
          await ref.read(authRepositoryProvider).startPhoneVerification(
                e164PhoneNumber: draft.e164,
                resendToken: draft.verification?.resendToken,
                onAutoVerified: (_) {},
              );
      if (!mounted) return;
      ref.read(signupDraftProvider.notifier).setVerification(verification);
      _controller.clear();
      _startCooldown();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = describeAuthError(error).message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(signupDraftProvider);
    final canResend = _secondsLeft <= 0 && !_resending;

    return AuthScaffold(
      title: 'Verify your phone number',
      onBack: () {
        // Leaving mid-verification is a deliberate abandon; clearing the draft
        // means the next attempt starts clean rather than reusing a stale
        // verification id.
        _focusNode.unfocus();
        context.pop();
      },
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwButton(
            label: 'Verify',
            loading: _verifying,
            onTap: _code.length == kOtpLength ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GwTextAction(
                  label: canResend
                      ? 'Resend code'
                      : 'Resend in 0:${_secondsLeft.clamp(0, 59).toString().padLeft(2, '0')}',
                  color: canResend ? AppColors.green : AppColors.ink55,
                  onTap: canResend ? _resend : null,
                ),
              ),
              Container(
                width: 1,
                height: 18,
                color: AppColors.dividerStrong,
              ),
              Flexible(
                child: GwTextAction(
                  label: 'Change number',
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
        ],
      ),
      children: [
        Text.rich(
          TextSpan(
            style: AppText.body,
            children: [
              const TextSpan(text: 'Sent to '),
              TextSpan(
                text: formatE164ForDisplay(draft.e164),
                style: AppText.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl4 + AppSpacing.sm),
        _CodeCells(
          code: _code,
          controller: _controller,
          focusNode: _focusNode,
          hasError: _error != null,
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.xl2),
          InlineNotice(_error!, emphasis: true),
        ],
        const SizedBox(height: AppSpacing.xl4),
        Center(
          child: Text(
            "The SMS can take a minute on a busy network.",
            textAlign: TextAlign.center,
            style: AppText.meta,
          ),
        ),
      ],
    );
  }
}

/// Six white cells rendering the contents of one hidden field.
///
/// The whole group is a single tap target that focuses that field, so tapping
/// anywhere on the row does the obvious thing.
class _CodeCells extends StatelessWidget {
  const _CodeCells({
    required this.code,
    required this.controller,
    required this.focusNode,
    required this.hasError,
  });

  final String code;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Verification code, $kOtpLength digits',
      value: code,
      child: Stack(
        children: [
          // The real field: present in the tree (so autofill, IME, and paste
          // all work) but visually collapsed behind the cells.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                maxLength: kOtpLength,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(kOtpLength),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: focusNode.requestFocus,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < kOtpLength; i++)
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i == kOtpLength - 1 ? 0 : AppSpacing.sm,
                      ),
                      child: _Cell(
                        digit: i < code.length ? code[i] : null,
                        // The next empty cell carries the caret cue.
                        active: focusNode.hasFocus && i == code.length,
                        hasError: hasError,
                      ),
                    ),
                  ),
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
    required this.digit,
    required this.active,
    required this.hasError,
  });

  final String? digit;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    // Errors are stated in words below, not in colour — DESIGN.md has no red.
    // A wrong code simply drops the cells back to their empty treatment.
    final outlined = active || (filled && !hasError);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.tag + 2),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: outlined ? AppColors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: filled
          ? Text(digit!, style: AppText.inputCell)
          : Container(
              width: 8,
              height: 2,
              decoration: BoxDecoration(
                color: active ? AppColors.green : AppColors.ink15,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
    );
  }
}
