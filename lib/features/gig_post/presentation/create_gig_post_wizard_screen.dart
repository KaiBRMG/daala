import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/category_field_spec.dart';
import '../../../core/models/gig_category.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_chip.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/map_placeholder.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/wizard_scaffold.dart';
import '../application/gig_post_wizard_controller.dart';
import '../domain/gig_post_draft.dart';

/// Create Gig Post Wizard — same scaffold and pattern as the Gig Request
/// wizard, with the DESIGN.md §3.4 deltas.
class CreateGigPostWizardScreen extends ConsumerStatefulWidget {
  const CreateGigPostWizardScreen({super.key});

  @override
  ConsumerState<CreateGigPostWizardScreen> createState() =>
      _CreateGigPostWizardScreenState();
}

class _CreateGigPostWizardScreenState
    extends ConsumerState<CreateGigPostWizardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gigPostWizardProvider.notifier).reset();
    });
  }

  Future<void> _saveAndExit() async {
    await ref.read(gigPostWizardProvider.notifier).saveDraft();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Draft saved')));
    context.go(RoutePaths.dashboard);
  }

  Future<void> _continueOrSubmit() async {
    final controller = ref.read(gigPostWizardProvider.notifier);
    final state = ref.read(gigPostWizardProvider);
    if (state.step != GigPostWizardStep.review) {
      controller.next();
      return;
    }
    final created = await controller.submit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gig Post published')));
    context.pushReplacement(RoutePaths.gigPost(created.id));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gigPostWizardProvider);
    final controller = ref.read(gigPostWizardProvider.notifier);

    final (question, helper) = switch (state.step) {
      GigPostWizardStep.title => (
          'What service do you offer?',
          'A clear title helps Consumers find you.'
        ),
      GigPostWizardStep.category => (
          'Pick a category',
          'Choose "Other" if nothing fits.'
        ),
      GigPostWizardStep.location => (
          'Where do you work?',
          'Consumers nearby will see your Gig Post first.'
        ),
      GigPostWizardStep.pricing => ('How do you price it?', null),
      GigPostWizardStep.details => (
          'Describe your service',
          'What is included, and what makes you the right choice?'
        ),
      GigPostWizardStep.categoryFields => (
          'A few specifics',
          'These help Consumers choose the right Merchant.'
        ),
      GigPostWizardStep.portfolio => (
          'Add portfolio photos',
          'Optional in the skeleton — photos build trust.'
        ),
      GigPostWizardStep.review => (
          'Review your Gig Post',
          'Tap any row to edit it.'
        ),
    };

    return WizardScaffold(
      stepIndex: state.stepIndex,
      stepCount: GigPostWizardStep.values.length,
      question: question,
      helper: helper,
      continueLabel: state.step == GigPostWizardStep.review
          ? 'Publish Gig Post'
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

  final GigPostWizardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(gigPostWizardProvider.notifier);
    final draft = state.draft;

    switch (state.step) {
      case GigPostWizardStep.title:
        return _DraftTextField(
          key: const ValueKey('title'),
          hint: 'e.g. Certified electrician — CoC & repairs',
          initialValue: draft.title,
          onChanged: (value) =>
              controller.updateDraft(draft.copyWith(title: value)),
        );
      case GigPostWizardStep.category:
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
              _DraftTextField(
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
      case GigPostWizardStep.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DraftTextField(
              key: const ValueKey('serviceArea'),
              label: 'Service area',
              hint: 'e.g. Mitchells Plain & surrounds',
              initialValue: draft.serviceArea,
              onChanged: (value) => controller
                  .updateDraft(draft.copyWith(serviceArea: value)),
            ),
            const SizedBox(height: DaalaSpacing.s16),
            if (draft.serviceArea.isNotEmpty)
              const MapPlaceholder(caption: 'Your service area'),
          ],
        );
      case GigPostWizardStep.pricing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: DaalaSpacing.s8,
              runSpacing: DaalaSpacing.s8,
              children: [
                for (final model in PricingModel.values)
                  DaalaChip(
                    label: model.label,
                    selected: draft.pricingModel == model,
                    onTap: () => controller
                        .updateDraft(draft.copyWith(pricingModel: model)),
                  ),
              ],
            ),
            const SizedBox(height: DaalaSpacing.s24),
            _DraftTextField(
              key: const ValueKey('price'),
              label: draft.pricingModel == PricingModel.hourly
                  ? 'Rate per hour'
                  : 'Price',
              hint: '0',
              prefixText: 'R ',
              keyboardType: TextInputType.number,
              digitsOnly: true,
              textStyle: DaalaTextStyles.moneyMd
                  .copyWith(color: DaalaColors.ink900),
              initialValue: draft.priceZarMinor == null
                  ? ''
                  : '${draft.priceZarMinor! ~/ 100}',
              onChanged: (value) {
                final rand = int.tryParse(value.trim());
                controller.updateDraft(
                    draft.copyWith(priceZarMinor: (rand ?? 0) * 100));
              },
            ),
          ],
        );
      case GigPostWizardStep.details:
        return _DraftTextField(
          key: const ValueKey('description'),
          label: 'Description',
          hint: 'Describe your service, what is included and your '
              'experience.',
          maxLines: 6,
          initialValue: draft.description,
          onChanged: (value) =>
              controller.updateDraft(draft.copyWith(description: value)),
        );
      case GigPostWizardStep.categoryFields:
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
                _DraftTextField(
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
      case GigPostWizardStep.portfolio:
        return Wrap(
          spacing: DaalaSpacing.s8,
          runSpacing: DaalaSpacing.s8,
          children: [
            for (var i = 0; i < draft.portfolioCount; i++)
              const MediaPlaceholder(
                  width: DaalaSizes.galleryTile,
                  height: DaalaSizes.galleryTile),
            // Mock picker: tapping the add tile appends a placeholder.
            InkWell(
              borderRadius: BorderRadius.circular(DaalaRadius.rMd),
              onTap: () => controller.updateDraft(draft.copyWith(
                  portfolioCount: draft.portfolioCount + 1)),
              child: Container(
                width: DaalaSizes.galleryTile,
                height: DaalaSizes.galleryTile,
                decoration: BoxDecoration(
                  color: DaalaColors.bgSecondary,
                  borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                  border: Border.all(
                      color: DaalaColors.borderDefault,
                      width: DaalaSizes.borderWidth),
                ),
                child: const Icon(Icons.add_a_photo_outlined,
                    color: DaalaColors.ink500, size: DaalaSizes.iconLg),
              ),
            ),
          ],
        );
      case GigPostWizardStep.review:
        final rows = <(String, String, GigPostWizardStep)>[
          ('Title', draft.title, GigPostWizardStep.title),
          (
            'Category',
            draft.category == GigCategory.other
                ? 'Other — ${draft.customCategory}'
                : draft.category?.label ?? '',
            GigPostWizardStep.category
          ),
          ('Service area', draft.serviceArea, GigPostWizardStep.location),
          (
            'Pricing',
            '${draft.pricingModel?.label ?? ''} · '
                '${formatZar(draft.priceZarMinor ?? 0)}',
            GigPostWizardStep.pricing
          ),
          ('Description', draft.description, GigPostWizardStep.details),
          (
            'Portfolio',
            draft.portfolioCount == 0
                ? 'No photos'
                : '${draft.portfolioCount} photo'
                    '${draft.portfolioCount == 1 ? '' : 's'}',
            GigPostWizardStep.portfolio
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
                  showDivider: label != rows.last.$1,
                  trailing: const Icon(Icons.edit_outlined,
                      color: DaalaColors.ink500, size: DaalaSizes.iconMd),
                  onTap: () => controller.jumpToStep(step),
                ),
            ],
          ),
        );
    }
  }
}

/// Text field that survives step rebuilds (same pattern as the Gig
/// Request wizard).
class _DraftTextField extends StatefulWidget {
  const _DraftTextField({
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
  State<_DraftTextField> createState() => _DraftTextFieldState();
}

class _DraftTextFieldState extends State<_DraftTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

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
