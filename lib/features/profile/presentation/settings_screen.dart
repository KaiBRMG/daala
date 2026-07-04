import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/daala_segmented.dart';

/// Settings (DESIGN.md §3.13): mode switch, verification status,
/// notification toggles, legal links, Sign out (destructive).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Settings',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          children: [
            Text('MODE',
                style: DaalaTextStyles.overline
                    .copyWith(color: DaalaColors.ink500)),
            const SizedBox(height: DaalaSpacing.s8),
            DaalaSegmented(
              expanded: true,
              segments: const ['Consumer', 'Merchant'],
              selectedIndex: session.mode == UserMode.consumer ? 0 : 1,
              onChanged: (i) => session.setMode(
                  i == 0 ? UserMode.consumer : UserMode.merchant),
            ),
            const SizedBox(height: DaalaSpacing.sectionGap),
            Text('VERIFICATION',
                style: DaalaTextStyles.overline
                    .copyWith(color: DaalaColors.ink500)),
            DaalaListRow(
              leading: LeadingCircleIcon(
                icon: session.isVerified
                    ? Icons.verified
                    : Icons.verified_user_outlined,
              ),
              title: session.isVerified
                  ? 'Identity verified'
                  : 'Identity not verified',
              subtitle: session.isVerified
                  ? 'Your verification badge is active'
                  : 'Verify to unlock your badge',
              trailing: session.isVerified
                  ? null
                  : const Icon(Icons.chevron_right,
                      color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              onTap: session.isVerified
                  ? null
                  : () => context.push(RoutePaths.verifyIdentity),
              showDivider: false,
            ),
            const SizedBox(height: DaalaSpacing.sectionGap),
            Text('NOTIFICATIONS',
                style: DaalaTextStyles.overline
                    .copyWith(color: DaalaColors.ink500)),
            _toggleRow('Push notifications', _pushEnabled,
                (value) => setState(() => _pushEnabled = value)),
            _toggleRow('Email updates', _emailEnabled,
                (value) => setState(() => _emailEnabled = value)),
            const SizedBox(height: DaalaSpacing.sectionGap),
            Text('LEGAL',
                style: DaalaTextStyles.overline
                    .copyWith(color: DaalaColors.ink500)),
            DaalaListRow(
              title: 'Terms of Service',
              trailing: const Icon(Icons.chevron_right,
                  color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              // TODO(spec): legal documents deferred — no target defined.
              onTap: () {},
            ),
            DaalaListRow(
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right,
                  color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              showDivider: false,
              onTap: () {},
            ),
            const SizedBox(height: DaalaSpacing.s32),
            DaalaButton(
              label: 'Sign out',
              variant: DaalaButtonVariant.destructiveText,
              onPressed: () {
                session.signOut();
                context.go(RoutePaths.splash);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink900)),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
