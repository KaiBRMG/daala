import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/category_field_spec.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/daala_segmented.dart';
import '../../../core/widgets/map_placeholder.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/wizard_scaffold.dart';
import '../application/gig_request_wizard_controller.dart';
import '../domain/gig_request_draft.dart';

const List<String> _mockAddressSuggestions = [
  '12 Ncumo Road, Khayelitsha',
  '48 Voortrekker Road, Goodwood',
  '7 Klipfontein Road, Athlone',
];

/// Create Gig Request Wizard (DESIGN.md §3.4) — one decision per screen.
class CreateGigRequestWizardScreen extends ConsumerStatefulWidget {
  const CreateGigRequestWizardScreen({super.key});

  @override
  ConsumerState<CreateGigRequestWizardScreen> createState() =>
      _CreateGigRequestWizardScreenState();
}

class _CreateGigRequestWizardScreenState
    extends ConsumerState<CreateGigRequestWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gigRequestWizardProvider.notifier).reset();
    });
  }

  Future<void> _saveAndExit() async {
    await ref.read(gigRequestWizardProvider.notifier).saveDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft saved')));
    context.go(RoutePaths.dashboard);
  }

  Future<void> _continueOrSubmit() async {
    final controller = ref.read(gigRequestWizardProvider.notifier);
    final state = ref.read(gigRequestWizardProvider);
    if (state.step != GigRequestWizardStep.review) {
      controller.next();
      return;
    }
    final created = await controller.submit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gig Request posted')));
    context.pushReplacement(RoutePaths.gigRequest(created.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gigRequestWizardProvider);
    final controller = ref.read(gigRequestWizardProvider.notifier);

    final (question, helper) = switch (state.step) {
      GigRequestWizardStep.title => (
          'What do you need done?',
          'A short, clear title helps Merchants understand the job.'
        ),
      GigRequestWizardStep.category => (
          'Pick a category',
          'Choose "Other" if nothing fits.'
        ),
      GigRequestWizardStep.location => (
          'Where should it happen?',
          null
        ),
      GigRequestWizardStep.when => ('When do you need it?', null),
      GigRequestWizardStep.budget => (
          'What is your budget?',
          'You can negotiate offers later.'
        ),
      GigRequestWizardStep.details => (
          'Add the details',
          'Describe the job and add photos if they help.'
        ),
      GigRequestWizardStep.categoryFields => (
          'A few specifics',
          'These help Merchants give accurate Offers.'
        ),
      GigRequestWizardStep.review => (
          'Review your Gig Request',
          'Tap any row to edit it.'
        ),
    };

    return WizardScaffold(
      stepIndex: state.stepIndex,
      stepCount: GigRequestWizardStep.values.length,
      question: question,
      helper: helper,
      continueLabel: state.step == GigRequestWizardStep.review
          ? 'Post Gig Request'
          : 'Continue',
      continueEnabled: controller.canContinue,
      submitting: state.submitting,
      onContinue: _continueOrSubmit,
      onBack: () {
        if (!controller.back()) context.pop();
      },
      onSaveAndExit: _saveAndExit,
      body: _StepBody(state: state),
    );
  }
}

class _StepBody extends ConsumerWidget {
  const _StepBody({required this.state});

  final GigRequestWizardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gigRequestWizardProvider.notifier);
    final draft = state.draft;

    switch (state.step) {
      case GigRequestWizardStep.title:
        return _TitleStep(draft: draft, controller: controller);
      case GigRequestWizardStep.category:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: DaalaSpacing.s8,
              runSpacing: DaalaSpacing.s8,
              children: [
                for (final category in GigCategory.values)
                  DaalaChip(
                    label: category.label,
                    selected: draft.category == category,
                    onTap: () => controller
                        .updateDraft(draft.copyWith(category: category)),
                  ),
              ],
            ),
            if (draft.category == GigCategory.other) ...[
              const SizedBox(height: DaalaSpacing.s16),
              _RebuildSafeTextField(
                key: const ValueKey('customCategory'),
                label: 'Describe the category',
                hint: 'e.g. Appliance repair',
                initialValue: draft.customCategory,
                onChanged: (value) => controller
                    .updateDraft(draft.copyWith(customCategory: value)),
              ),
            ],
          ],
        );
      case GigRequestWizardStep.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DaalaSegmented(
              expanded: true,
              segments: const ['In person', 'Online'],
              selectedIndex:
                  draft.locationType == LocationType.inPerson ? 0 : 1,
              onChanged: (i) => controller.updateDraft(draft.copyWith(
                  locationType: i == 0
                      ? LocationType.inPerson
                      : LocationType.online)),
            ),
            if (draft.locationType == LocationType.inPerson) ...[
              const SizedBox(height: DaalaSpacing.s24),
              _RebuildSafeTextField(
                key: const ValueKey('address'),
                label: 'Address',
                hint: 'Start typing your address',
                initialValue: draft.address,
                onChanged: (value) =>
                    controller.updateDraft(draft.copyWith(address: value)),
              ),
              const SizedBox(height: DaalaSpacing.s8),
              // Mock autocomplete suggestions (live lookup deferred).
              for (final suggestion in _mockAddressSuggestions)
                DaalaListRow(
                  leading: const Icon(Icons.place_outlined,
                      color: DaalaColors.ink500, size: DaalaSizes.iconLg),
                  title: suggestion,
                  onTap: () => controller
                      .updateDraft(draft.copyWith(address: suggestion)),
                ),
              const SizedBox(height: DaalaSpacing.s16),
              if (draft.address.isNotEmpty)
                const MapPlaceholder(caption: 'Confirm your location'),
            ],
          ],
        );
      case GigRequestWizardStep.when:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: DaalaSpacing.s8,
              runSpacing: DaalaSpacing.s8,
              children: [
                for (final whenType in WhenType.values)
                  DaalaChip(
                    label: whenType.label,
                    selected: draft.whenType == whenType,
                    onTap: () => controller
                        .updateDraft(draft.copyWith(whenType: whenType)),
                  ),
              ],
            ),
            if (draft.whenType == WhenType.onADate) ...[
              const SizedBox(height: DaalaSpacing.s24),
              DaalaCard(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: draft.date ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    controller.updateDraft(draft.copyWith(date: picked));
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: DaalaColors.brandGreen900,
                        size: DaalaSizes.iconLg),
                    const SizedBox(width: DaalaSpacing.s12),
                    Text(
                      draft.date == null
                          ? 'Pick a date'
                          : formatShortDate(draft.date!),
                      style: DaalaTextStyles.body
                          .copyWith(color: DaalaColors.ink900),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      case GigRequestWizardStep.budget:
        return _RebuildSafeTextField(
          key: const ValueKey('budget'),
          label: 'Budget',
          hint: '0',
          prefixText: 'R ',
          keyboardType: TextInputType.number,
          digitsOnly: true,
          textStyle:
              DaalaTextStyles.moneyMd.copyWith(color: DaalaColors.ink900),
          initialValue: draft.budgetZarMinor == null
              ? ''
              : '${draft.budgetZarMinor! ~/ 100}',
          onChanged: (value) {
            final rand = int.tryParse(value.trim());
            controller.updateDraft(
                draft.copyWith(budgetZarMinor: (rand ?? 0) * 100));
          },
        );
      case GigRequestWizardStep.details:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RebuildSafeTextField(
              key: const ValueKey('description'),
              label: 'Description',
              hint: 'Describe what needs doing, any materials, and '
                  'anything a Merchant should know.',
              maxLines: 6,
              initialValue: draft.description,
              onChanged: (value) => controller
                  .updateDraft(draft.copyWith(description: value)),
            ),
            const SizedBox(height: DaalaSpacing.s24),
            Text('Photos',
                style: DaalaTextStyles.caption
                    .copyWith(color: DaalaColors.ink500)),
            const SizedBox(height: DaalaSpacing.s8),
            Wrap(
              spacing: DaalaSpacing.s8,
              runSpacing: DaalaSpacing.s8,
              children: [
                for (var i = 0; i < draft.photoCount; i++)
                  const MediaPlaceholder(
                      width: DaalaSizes.galleryTile,
                      height: DaalaSizes.galleryTile),
                // Mock picker: tapping the add tile appends a placeholder.
                InkWell(
                  borderRadius:
                      BorderRadius.circular(DaalaRadius.rMd),
                  onTap: () => controller.updateDraft(
                      draft.copyWith(photoCount: draft.photoCount + 1)),
                  child: Container(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile,
                    decoration: BoxDecoration(
                      color: DaalaColors.bgSecondary,
                      borderRadius:
                          BorderRadius.circular(DaalaRadius.rMd),
                      border: Border.all(
                          color: DaalaColors.borderDefault,
                          width: DaalaSizes.borderWidth),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        color: DaalaColors.ink500,
                        size: DaalaSizes.iconLg),
                  ),
                ),
              ],
            ),
          ],
        );
      case GigRequestWizardStep.categoryFields:
        final specs = categoryFieldSchema[draft.category] ?? const [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final spec in specs) ...[
              if (spec.type == CategoryFieldType.toggle)
                Row(
                  children: [
                    Expanded(
                      child: Text(spec.label,
                          style: DaalaTextStyles.body
                              .copyWith(color: DaalaColors.ink900)),
                    ),
                    Switch(
                      value:
                          draft.categoryFields[spec.key] as bool? ?? false,
                      onChanged: (value) => controller.updateDraft(
                          draft.copyWith(categoryFields: {
                        ...draft.categoryFields,
                        spec.key: value,
                      })),
                    ),
                  ],
                )
              else
                _RebuildSafeTextField(
                  key: ValueKey(spec.key),
                  label: spec.label,
                  hint: spec.helper,
                  initialValue:
                      draft.categoryFields[spec.key] as String? ?? '',
                  onChanged: (value) => controller.updateDraft(
                      draft.copyWith(categoryFields: {
                    ...draft.categoryFields,
                    spec.key: value,
                  })),
                ),
              const SizedBox(height: DaalaSpacing.s16),
            ],
          ],
        );
      case GigRequestWizardStep.review:
        return _ReviewStep(draft: draft, controller: controller);
    }
  }
}

class _TitleStep extends StatelessWidget {
  const _TitleStep({required this.draft, required this.controller});

  final GigRequestDraft draft;
  final GigRequestWizardController controller;

  @override
  Widget build(BuildContext context) {
    return _RebuildSafeTextField(
      key: const ValueKey('title'),
      hint: 'e.g. Fix a leaking pipe',
      initialValue: draft.title,
      onChanged: (value) =>
          controller.updateDraft(draft.copyWith(title: value)),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.draft, required this.controller});

  final GigRequestDraft draft;
  final GigRequestWizardController controller;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String, GigRequestWizardStep)>[
      ('Title', draft.title, GigRequestWizardStep.title),
      (
        'Category',
        draft.category == GigCategory.other
            ? 'Other — ${draft.customCategory}'
            : draft.category?.label ?? '',
        GigRequestWizardStep.category
      ),
      (
        'Location',
        draft.locationType == LocationType.online
            ? 'Online'
            : draft.address,
        GigRequestWizardStep.location
      ),
      (
        'When',
        draft.whenType == WhenType.onADate && draft.date != null
            ? formatShortDate(draft.date!)
            : draft.whenType?.label ?? '',
        GigRequestWizardStep.when
      ),
      (
        'Budget',
        formatZar(draft.budgetZarMinor ?? 0),
        GigRequestWizardStep.budget
      ),
      ('Details', draft.description, GigRequestWizardStep.details),
      if (draft.photoCount > 0)
        (
          'Photos',
          '${draft.photoCount} photo${draft.photoCount == 1 ? '' : 's'}',
          GigRequestWizardStep.details
        ),
    ];

    return DaalaCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (label, value, step) in rows)
            DaalaListRow(
              title: label,
              subtitle: value,
              showDivider: step != rows.last.$3,
              trailing: const Icon(Icons.edit_outlined,
                  color: DaalaColors.ink500, size: DaalaSizes.iconMd),
              onTap: () => controller.jumpToStep(step),
            ),
        ],
      ),
    );
  }
}

/// A text field that survives step rebuilds: seeds its controller from the
/// draft once, then pushes edits up via [onChanged].
class _RebuildSafeTextField extends StatefulWidget {
  const _RebuildSafeTextField({
    super.key,
    this.label,
    this.hint,
    this.prefixText,
    this.maxLines = 1,
    this.keyboardType,
    this.digitsOnly = false,
    this.textStyle,
    required this.initialValue,
    required this.onChanged,
  });

  final String? label;
  final String? hint;
  final String? prefixText;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool digitsOnly;
  final TextStyle? textStyle;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_RebuildSafeTextField> createState() =>
      _RebuildSafeTextFieldState();
}

class _RebuildSafeTextFieldState extends State<_RebuildSafeTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void didUpdateWidget(covariant _RebuildSafeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External draft change (e.g. tapping an address suggestion).
    if (widget.initialValue != _controller.text &&
        widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaalaInput(
      label: widget.label,
      hint: widget.hint,
      controller: _controller,
      prefixText: widget.prefixText,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters:
          widget.digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
      textStyle: widget.textStyle,
      onChanged: widget.onChanged,
    );
  }
}
