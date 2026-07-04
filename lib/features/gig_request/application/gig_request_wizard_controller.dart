import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_field_spec.dart';
import '../../../core/models/gig_category.dart';
import '../domain/gig_request.dart';
import '../domain/gig_request_draft.dart';
import 'gig_request_providers.dart';

/// Wizard steps in fixed order (DESIGN.md §3.4).
enum GigRequestWizardStep {
  title,
  category,
  location,
  when,
  budget,
  details,
  categoryFields,
  review,
}

class GigRequestWizardState {
  const GigRequestWizardState({
    this.stepIndex = 0,
    this.draft = const GigRequestDraft(),
    this.submitting = false,
  });

  final int stepIndex;
  final GigRequestDraft draft;
  final bool submitting;

  GigRequestWizardStep get step =>
      GigRequestWizardStep.values[stepIndex];

  GigRequestWizardState copyWith({
    int? stepIndex,
    GigRequestDraft? draft,
    bool? submitting,
  }) {
    return GigRequestWizardState(
      stepIndex: stepIndex ?? this.stepIndex,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
    );
  }
}

class GigRequestWizardController extends Notifier<GigRequestWizardState> {
  @override
  GigRequestWizardState build() => const GigRequestWizardState();

  void reset() => state = const GigRequestWizardState();

  void updateDraft(GigRequestDraft draft) =>
      state = state.copyWith(draft: draft);

  bool get _categoryHasFields =>
      (categoryFieldSchema[state.draft.category] ?? const []).isNotEmpty;

  /// Per-step validity gates the Continue button.
  bool get canContinue {
    final draft = state.draft;
    switch (state.step) {
      case GigRequestWizardStep.title:
        return draft.title.trim().isNotEmpty;
      case GigRequestWizardStep.category:
        if (draft.category == null) return false;
        if (draft.category == GigCategory.other) {
          return draft.customCategory.trim().isNotEmpty;
        }
        return true;
      case GigRequestWizardStep.location:
        return draft.locationType == LocationType.online ||
            draft.address.trim().isNotEmpty;
      case GigRequestWizardStep.when:
        if (draft.whenType == null) return false;
        return draft.whenType != WhenType.onADate || draft.date != null;
      case GigRequestWizardStep.budget:
        return (draft.budgetZarMinor ?? 0) > 0;
      case GigRequestWizardStep.details:
        return draft.description.trim().isNotEmpty;
      case GigRequestWizardStep.categoryFields:
      case GigRequestWizardStep.review:
        return true;
    }
  }

  void next() {
    var index = state.stepIndex + 1;
    // "Other" (or a schema-less category) skips the category-fields step.
    if (GigRequestWizardStep.values[index] ==
            GigRequestWizardStep.categoryFields &&
        !_categoryHasFields) {
      index++;
    }
    if (index < GigRequestWizardStep.values.length) {
      state = state.copyWith(stepIndex: index);
    }
  }

  /// Returns false when already on the first step (caller closes wizard).
  bool back() {
    if (state.stepIndex == 0) return false;
    var index = state.stepIndex - 1;
    if (GigRequestWizardStep.values[index] ==
            GigRequestWizardStep.categoryFields &&
        !_categoryHasFields) {
      index--;
    }
    state = state.copyWith(stepIndex: index);
    return true;
  }

  void jumpToStep(GigRequestWizardStep step) =>
      state = state.copyWith(stepIndex: step.index);

  Future<GigRequest> submit() async {
    state = state.copyWith(submitting: true);
    try {
      return await ref
          .read(gigRequestRepositoryProvider)
          .create(state.draft);
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  Future<void> saveDraft() =>
      ref.read(gigRequestRepositoryProvider).saveDraft(state.draft);
}

final gigRequestWizardProvider = NotifierProvider<
    GigRequestWizardController,
    GigRequestWizardState>(GigRequestWizardController.new);
