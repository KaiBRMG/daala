/// Screen 6A — the deferred notifications ask.
///
/// Not part of the signup flow by design. It is raised the first time the user
/// does something that *creates* a reason to be notified — applying for a gig,
/// hiring someone, sending a first message — because a permission prompt asked
/// at that moment converts far better than one fired at launch, and a denied
/// iOS prompt can never be asked again.
///
/// Call [showNotificationsPrompt] from those trigger points; it no-ops if the
/// user has already answered.
///
/// **The OS dialog itself is not wired yet.** It needs `firebase_messaging`,
/// which lands in Phase 5 with real push. Until then this records the user's
/// preference so the eventual request happens once, silently, at the right
/// moment. See CLAUDE.md § Deferred to later phases.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../widgets/ui.dart';

const String _answeredKey = 'daala.notifications.answered';
const String _optInKey = 'daala.notifications.personalised';

/// Shows the prompt unless it has already been answered on this device.
///
/// Returns `true` if the user opted in.
Future<bool> showNotificationsPrompt(
  BuildContext context, {
  required String reason,
}) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_answeredKey) ?? false) return false;
  if (!context.mounted) return false;

  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _NotificationsSheet(reason: reason),
  );

  await prefs.setBool(_answeredKey, true);
  return result ?? false;
}

class _NotificationsSheet extends ConsumerStatefulWidget {
  const _NotificationsSheet({required this.reason});

  /// The concrete thing that just happened, woven into the copy — "so you know
  /// the moment Marlo replies" beats a generic plea.
  final String reason;

  @override
  ConsumerState<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends ConsumerState<_NotificationsSheet> {
  bool _personalised = true;
  bool _working = false;

  Future<void> _accept() async {
    setState(() => _working = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_optInKey, _personalised);
    // TODO(phase5): request the OS permission through firebase_messaging here,
    // then register the FCM token against users/{uid}/private/devices.
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.screen,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl3,
          20,
          AppSpacing.xl3,
          40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.ink15,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl4),
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.greenTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 26,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: AppSpacing.xl3),
            Text('Turn on notifications?', style: AppText.detailTitle),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.reason,
              style: AppText.body.copyWith(fontSize: 14, height: 1.55),
            ),
            const SizedBox(height: AppSpacing.xl4),
            GwCard(
              shadow: AppShadows.soft,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tips and suggestions', style: AppText.rowTitle),
                        const SizedBox(height: 3),
                        Text(
                          'Gigs that suit you, profile advice, and more',
                          style: AppText.meta.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _Toggle(
                    value: _personalised,
                    onChanged: (value) =>
                        setState(() => _personalised = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl4),
            GwButton(
              label: 'Yes, notify me',
              loading: _working,
              onTap: _accept,
            ),
            const SizedBox(height: AppSpacing.xs),
            GwTextAction(
              label: 'Not now',
              color: AppColors.ink55,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You can change this any time in your profile settings.',
              textAlign: TextAlign.center,
              style: AppText.meta,
            ),
          ],
        ),
      ),
    );
  }
}

/// The design's 46×28 pill toggle: green when on, ink-15 when off, with a 24px
/// white thumb crossing in 180ms.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 46,
          height: 28,
          padding: const EdgeInsets.all(2),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? AppColors.green : AppColors.ink15,
            borderRadius: BorderRadius.circular(AppRadius.tag),
          ),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
