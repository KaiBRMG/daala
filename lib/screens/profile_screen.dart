import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_repository.dart';
import '../auth/phone_format.dart';
import '../auth/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

/// The signed-in person's own profile: the public card other people see, then
/// the private account details only they see.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xs),
            _header(context),
            Expanded(
              // The shell only renders for a Ready session, so a null profile
              // is the brief moment around sign-out — show nothing rather than
              // a stranger's placeholder name.
              child: profile == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.only(
                          top: AppSpacing.xl4, bottom: 120),
                      children: [
                        _Identity(profile: profile),
                        const SizedBox(height: AppSpacing.xl4),
                        _Stats(profile: profile),
                        const SizedBox(height: AppSpacing.xl4),
                        Text('Reviews',
                            style: AppText.section.copyWith(fontSize: 15)),
                        const SizedBox(height: AppSpacing.md),
                        // TODO(phase4): reviews arrive with completed bookings.
                        // Until then every account truthfully has none.
                        const EmptyState(
                          'No reviews yet',
                          body: 'Reviews from people you work with will '
                              'show up here.',
                        ),
                        const SizedBox(height: AppSpacing.xl4),
                        Text('Account',
                            style: AppText.section.copyWith(fontSize: 15)),
                        const SizedBox(height: AppSpacing.md),
                        const _AccountCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Text('Profile',
              textAlign: TextAlign.center, style: AppText.appBarTitle),
        ),
        RoundIconButton(
          icon: Icons.account_balance_wallet_outlined,
          iconSize: 16,
          semanticLabel: 'Wallet',
          onTap: () => context.push('/wallet'),
        ),
      ],
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final rating = profile.ratingAverage;
    return Column(
      children: [
        InitialsAvatar(profile.initials, size: 84, fontSize: 28),
        const SizedBox(height: AppSpacing.lg),
        Text(profile.displayName,
            textAlign: TextAlign.center,
            style: AppText.metaStrong
                .copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: AppSpacing.xs),
        // A new account says so plainly rather than showing a zero rating,
        // which would read as a bad one.
        Text(
          profile.ratingCount == 0 || rating == null
              ? 'New on Daala'
              : '★ ${rating.toStringAsFixed(1)} · '
                  '${profile.ratingCount} '
                  '${profile.ratingCount == 1 ? 'review' : 'reviews'}',
          style: AppText.tag.copyWith(color: AppColors.orange, fontSize: 13),
        ),
        if (profile.verified) ...[
          const SizedBox(height: AppSpacing.md),
          const StatusPill('ID verified'),
        ],
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final since = profile.createdAt?.year;
    return Row(
      children: [
        Expanded(child: _statCard('${profile.gigsCompleted}', 'Gigs Done')),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _statCard('${profile.ratingCount}', 'Reviews')),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child: _statCard(since == null ? '—' : '$since', 'Member Since')),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return GwCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Text(value,
              style: AppText.metaStrong
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: AppText.meta.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

/// Private details — phone, email and its confirmation state — plus sign-out.
///
/// The email row is the one place a user can see whether their backup way in
/// actually works, and re-send the link if it doesn't.
class _AccountCard extends ConsumerStatefulWidget {
  const _AccountCard();

  @override
  ConsumerState<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<_AccountCard> {
  bool _sending = false;
  bool _signingOut = false;
  String? _notice;

  Future<void> _resend(String email) async {
    setState(() {
      _sending = true;
      _notice = null;
    });
    try {
      await ref.read(pendingEmailStoreProvider).savePendingEmail(email);
      await ref.read(authRepositoryProvider).sendEmailSignInLink(email);
      if (mounted) {
        setState(() => _notice = 'Link sent to $email. Open it on this phone.');
      }
    } catch (error) {
      if (mounted) setState(() => _notice = describeAuthError(error).message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _signingOut = true);
    // No navigation: the session goes to SignedOut and the router moves on.
    await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final contact = ref.watch(currentContactProvider).value;
    final authUser = ref.watch(authUserProvider).value;

    final phone = authUser?.phoneNumber ?? contact?.phoneNumber;
    final email = contact?.email ?? authUser?.email;
    // Confirmed means the address is a real credential on this uid — either
    // the Auth record carries it, or the link handler marked it verified.
    final emailConfirmed = (authUser?.email != null &&
            authUser!.email!.isNotEmpty) ||
        (contact?.emailVerified ?? false);

    return GwCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(
            label: 'Phone',
            value: phone == null || phone.isEmpty
                ? '—'
                : formatE164ForDisplay(phone),
          ),
          _divider(),
          _row(
            label: 'Email',
            value: email ?? 'Not added',
            status: email == null
                ? null
                : (emailConfirmed ? 'Confirmed' : 'Not confirmed yet'),
          ),
          if (email != null && !emailConfirmed) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl2, 0, AppSpacing.xl2, AppSpacing.md),
              child: Text(
                'Open the link we emailed you to make this your backup way in.',
                style: AppText.meta.copyWith(height: 1.45),
              ),
            ),
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl2, 0, AppSpacing.xl2, AppSpacing.sm),
                child: InlineNotice(_notice!, emphasis: true),
              ),
            GwTextAction(
              label: _sending ? 'Sending…' : 'Resend link',
              onTap: _sending ? null : () => _resend(email),
            ),
          ],
          _divider(),
          GwTextAction(
            label: _signingOut ? 'Signing out…' : 'Sign out',
            onTap: _signingOut ? null : _signOut,
          ),
        ],
      ),
    );
  }

  Widget _row({required String label, required String value, String? status}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl2, vertical: AppSpacing.xl),
      child: Row(
        children: [
          Text(label, style: AppText.label),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.value.copyWith(fontSize: 14)),
                if (status != null) ...[
                  const SizedBox(height: 2),
                  Text(status, style: AppText.meta),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
      height: 1, thickness: 1, color: AppColors.divider);
}
