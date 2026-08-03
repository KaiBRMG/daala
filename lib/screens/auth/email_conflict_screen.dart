/// Shown when an email address someone gave us turns out to already belong to
/// another Daala account.
///
/// ## Why this fires when it does
///
/// The conflict is **not knowable at the moment the address is typed.** Deciding
/// "is this email registered?" client-side is precisely the enumeration check
/// Firebase's email enumeration protection blocks, and defeating it would hand
/// anyone a way to test whether a given person has a Daala account. So the
/// address is accepted, a sign-in link is sent, and the collision surfaces on
/// the server the moment we try to attach it — in
/// [AuthRepository.completeEmailLink]. That is the earliest honest point.
///
/// Two ways out, because there are exactly two things that can be true: it's
/// their own older account (log into it), or they mistyped / used someone
/// else's (pick another address).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/auth_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/ui.dart';

class EmailConflictScreen extends ConsumerWidget {
  const EmailConflictScreen({super.key, required this.email});

  /// The address that collided. Shown back so the person can see whether it was
  /// simply a typo.
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Onboarding unfinished means the profile form is still ahead of them, so
    // "use a different email" has somewhere to go. Once onboarding is done the
    // address is changed from the profile screen instead — Phase 5.
    final canChangeNow = ref.watch(sessionProvider).value is NeedsOnboarding;

    return AuthScaffold(
      title: 'That email is already in use',
      subtitle: 'There is already a Daala account using this address. An '
          'address can only belong to one account, so that it always points at '
          'one wallet and one history.',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GwButton(
            label: 'Log in with Email',
            tone: GwButtonTone.green,
            onTap: () => context.go('/auth/email'),
          ),
          const SizedBox(height: AppSpacing.lg),
          GwTextAction(
            label: canChangeNow ? 'Use a different email' : 'Continue to Daala',
            onTap: () async {
              // Clear the stored address so the next link doesn't complete
              // against the one that just failed.
              await ref.read(pendingEmailStoreProvider).clearPendingEmail();
              if (!context.mounted) return;
              context.go(canChangeNow ? '/auth/profile' : '/home');
            },
          ),
        ],
      ),
      children: [
        GwCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl2,
            vertical: AppSpacing.xl,
          ),
          shadow: AppShadows.soft,
          child: Row(
            children: [
              const Icon(
                Icons.alternate_email_rounded,
                size: 18,
                color: AppColors.green,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  email,
                  style: AppText.value.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl4),
        Text(
          'If that older account is yours, log in with this address and carry '
          'on there. If it isn’t — or you mistyped — use another address.',
          style: AppText.body,
        ),
      ],
    );
  }
}
