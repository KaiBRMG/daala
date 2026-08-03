/// Landing screen for an opened email sign-in link.
///
/// Reached by deep link at `/auth/email-link?...` on the App Links / Universal
/// Links domain. Firebase Dynamic Links was shut down in August 2025, so this
/// route depends on `assetlinks.json` and `apple-app-site-association` being
/// served from that domain — see the Phase 2 setup tasks.
///
/// It handles both journeys the link can be on:
///
/// * **Same device, still signed in** — the onboarding case. The email gets
///   *linked* to the existing phone account, and this screen confirms it and
///   bows out.
/// * **Different device, or signed out** — the login case. The link signs the
///   user in, resolving to their original account precisely because onboarding
///   linked the address.
///
/// If the address isn't stored locally (the link was opened on another device),
/// it asks for it rather than failing. Firebase requires the email back to stop
/// a leaked link signing anyone in, so this prompt is a security control, not a
/// papered-over bug.
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

class EmailLinkHandlerScreen extends ConsumerStatefulWidget {
  const EmailLinkHandlerScreen({super.key, required this.link});

  /// The full incoming URL, including the `oobCode` query parameter.
  final String link;

  @override
  ConsumerState<EmailLinkHandlerScreen> createState() =>
      _EmailLinkHandlerScreenState();
}

enum _Stage { working, needsEmail, done, failed }

class _EmailLinkHandlerScreenState
    extends ConsumerState<EmailLinkHandlerScreen> {
  final TextEditingController _email = TextEditingController();
  final FocusNode _focus = FocusNode();

  _Stage _stage = _Stage.working;
  String? _message;
  bool _wasLinkedToExisting = false;

  /// The address had no account, so Firebase created one. It has an email and
  /// nothing else, so a phone number is the next thing asked for.
  bool _isNewAccount = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _email.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    // A link has just arrived and is unspent, so re-arm the exemption. Without
    // this, a second link opened in the same session would be redirected away
    // before it could be used.
    ref.read(emailLinkHandledProvider.notifier).rearm();

    final repository = ref.read(authRepositoryProvider);
    if (!repository.isEmailSignInLink(widget.link)) {
      setState(() {
        _stage = _Stage.failed;
        _message = 'That link isn’t valid any more. Ask for a new one from the '
            'email login screen.';
      });
      return;
    }

    final stored = await ref.read(pendingEmailStoreProvider).readPendingEmail();
    if (stored == null || stored.isEmpty) {
      if (mounted) setState(() => _stage = _Stage.needsEmail);
      return;
    }
    await _complete(stored);
  }

  /// Gives control back to the router's redirect.
  ///
  /// The session refresh is *attempted* but never depended on. Signing in
  /// already emits on the auth state stream, which recomputes the session by
  /// itself; the explicit refresh only covers the link-while-signed-in case,
  /// where the uid never changed. Awaiting it unguarded is what pinned the user
  /// on this screen — one slow Firestore read and the release never ran.
  Future<void> _releaseToRouter() async {
    try {
      await ref
          .read(sessionProvider.notifier)
          .refresh()
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Stale by at most one auth-state emission, which is self-correcting.
    }
    if (!mounted) return;
    ref.read(emailLinkHandledProvider.notifier).release();
  }

  Future<void> _complete(String email) async {
    setState(() {
      _stage = _Stage.working;
      _message = null;
    });

    final wasSignedIn = ref.read(authRepositoryProvider).currentUser != null;
    try {
      final result = await ref.read(authRepositoryProvider).completeEmailLink(
            email: email,
            link: widget.link,
          );
      await ref.read(pendingEmailStoreProvider).clearPendingEmail();
      if (!mounted) return;
      setState(() {
        _stage = _Stage.done;
        _wasLinkedToExisting = wasSignedIn;
        _isNewAccount = result.isNewUser;
      });
      // Let the confirmation land, then hand back to the session redirect.
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _releaseToRouter();
    } catch (error) {
      if (!mounted) return;
      final failure = describeAuthError(error);
      // The address belongs to another account. That is a decision to make, not
      // an error to read, so it gets its own screen rather than a sentence.
      if (failure.code == 'email-already-in-use' ||
          failure.code == 'credential-already-in-use') {
        context.go('/auth/email-conflict', extra: email);
        return;
      }
      setState(() {
        _stage = _Stage.failed;
        _message = failure.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_stage) {
      _Stage.working => const _Working(),
      _Stage.needsEmail => _NeedsEmail(
          controller: _email,
          focusNode: _focus,
          onSubmit: () => _complete(_email.text.trim()),
        ),
      _Stage.done => _Done(
          linked: _wasLinkedToExisting,
          isNewAccount: _isNewAccount,
        ),
      _Stage.failed => _Failed(
          message: _message ?? 'That link didn’t work.',
          onRetry: () => context.go('/auth/email'),
        ),
    };
  }
}

class _Working extends StatelessWidget {
  const _Working();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
              ),
            ),
            const SizedBox(height: AppSpacing.xl3),
            Text('Signing you in…', style: AppText.cardTitle),
          ],
        ),
      ),
    );
  }
}

class _NeedsEmail extends StatelessWidget {
  const _NeedsEmail({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final valid = looksLikeEmail(controller.text);
    return AuthScaffold(
      title: 'Confirm your email',
      subtitle: 'You opened the link on a different device, so we need the '
          'address it was sent to. This is what stops a forwarded link from '
          'signing in the wrong person.',
      footer: GwButton(
        label: 'Continue',
        onTap: valid ? onSubmit : null,
      ),
      children: [
        FieldShell(
          label: 'Email address',
          focused: focusNode.hasFocus,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            autofillHints: const [AutofillHints.email],
            style: AppText.value.copyWith(fontSize: 17),
            cursorColor: AppColors.green,
            onSubmitted: (_) => valid ? onSubmit() : null,
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
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.linked, required this.isNewAccount});

  /// `true` when the email was attached to an existing account rather than
  /// used to sign in — the onboarding path.
  final bool linked;

  /// `true` when the address had no account and Firebase made one. Promising
  /// "taking you to Daala" here would be a lie: the next screen asks for a
  /// phone number.
  final bool isNewAccount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl4 * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.greenTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 34,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: AppSpacing.xl4),
              Text(
                switch ((linked, isNewAccount)) {
                  (true, _) => 'Email confirmed',
                  (false, true) => 'Email verified',
                  (false, false) => 'You’re in',
                },
                style: AppText.detailTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                switch ((linked, isNewAccount)) {
                  (true, _) => 'It’s now your backup way into this account if '
                      'you ever lose your phone.',
                  (false, true) => 'One more step — we just need a phone '
                      'number to finish setting you up.',
                  (false, false) => 'Taking you to Daala.',
                },
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'That link didn’t work',
      footer: GwButton(label: 'Send a new link', onTap: onRetry),
      children: [
        InlineNotice(message, emphasis: true),
        const SizedBox(height: AppSpacing.xl4),
        Text(
          'Sign-in links expire and can only be used once, which is what keeps '
          'them safe to send by email.',
          style: AppText.meta.copyWith(height: 1.5),
        ),
      ],
    );
  }
}
