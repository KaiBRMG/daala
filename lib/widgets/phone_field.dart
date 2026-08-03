/// The shared phone-number input: dial-region button, national-format field,
/// and the region picker behind it.
///
/// Two screens ask for a number — the primary phone login and the email-first
/// link-phone screen — and they have to format, normalise, and validate it
/// identically. Sharing the field is what guarantees that; two copies would
/// drift the moment either one is touched.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/phone_format.dart';
import '../theme/app_theme.dart';
import 'auth_scaffold.dart';
import 'ui.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.region,
    required this.onChanged,
    required this.onRegionTap,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final DialRegion region;
  final ValueChanged<String> onChanged;
  final VoidCallback onRegionTap;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: FieldShell(
        focused: focusNode.hasFocus,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _RegionButton(region: region, onTap: onRegionTap),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.telephoneNumber],
                style: AppText.inputValue,
                cursorColor: AppColors.green,
                inputFormatters: [NationalPhoneFormatter(region)],
                onChanged: onChanged,
                onSubmitted: (_) => onSubmitted?.call(),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: formatNationalDigits(
                    '0' * region.nationalLength,
                    region,
                  ).replaceAll('0', '·'),
                  hintStyle: AppText.inputValue.copyWith(
                    color: AppColors.ink40,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the region picker. Resolves to `null` if dismissed.
Future<DialRegion?> showRegionPicker(
  BuildContext context, {
  required DialRegion selected,
}) {
  return showModalBottomSheet<DialRegion>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    isScrollControlled: true,
    builder: (_) => _RegionPickerSheet(selected: selected),
  );
}

/// The dial-code button. A 44-tall white pill so it clears both platform touch
/// minimums, and it reads as tappable next to a plain input.
class _RegionButton extends StatelessWidget {
  const _RegionButton({required this.region, required this.onTap});

  final DialRegion region;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Country code, ${region.name} ${region.display}',
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.screen,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(region.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                region.display,
                style: AppText.value.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.ink55,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The region picker. Seven entries, so a plain sheet beats a search field —
/// searching a list you can see in full is friction, not help.
class _RegionPickerSheet extends StatelessWidget {
  const _RegionPickerSheet({required this.selected});

  final DialRegion selected;

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
            Row(
              children: [
                GwTextAction(label: 'Cancel', onTap: () => context.pop()),
                Expanded(
                  child: Text(
                    'Country',
                    textAlign: TextAlign.center,
                    style: AppText.appBarTitle.copyWith(fontSize: 17),
                  ),
                ),
                // Balances the Cancel action so the title sits truly centred.
                const SizedBox(width: 78),
              ],
            ),
            const SizedBox(height: AppSpacing.xl2),
            for (final region in kDialRegions) ...[
              GwCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl2,
                  vertical: AppSpacing.xl,
                ),
                shadow: AppShadows.soft,
                onTap: () => context.pop(region),
                child: Row(
                  children: [
                    Text(region.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(child: Text(region.name, style: AppText.value)),
                    Text(
                      region.display,
                      style: AppText.value.copyWith(color: AppColors.ink55),
                    ),
                    if (region.iso == selected.iso) ...[
                      const SizedBox(width: AppSpacing.md),
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.green,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Daala is live in South Africa and its neighbours.',
              textAlign: TextAlign.center,
              style: AppText.meta,
            ),
          ],
        ),
      ),
    );
  }
}
