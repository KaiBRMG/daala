import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_field_spec.dart';
import '../../../core/models/gig_category.dart';
import '../domain/gig_post.dart';
import '../domain/gig_post_draft.dart';
import 'gig_post_providers.dart';

/// Create Gig Post Wizard steps — same pattern as the Gig Request wizard
/// with the §3.4 deltas: step 4 is the pricing model (the separate budget
/// step folds into it) and a portfolio-media step is added.
// TODO(spec): §3.4 replaces "When" with pricing but leaves the standalone
// budget step ambiguous — the amount lives inside the pricing step here.
enum GigPostWizardStep {
  title,
  category,
  location,
  pricing,
  details,
  categoryFields,
  portfolio,
  review,
}

class GigPostWizardState {
  const GigPostWizardState({
    this.stepIndex = 0,
    this.draft = const GigPostDraft(),
    this.submitting = false,
  });

  final int stepIndex;
  final GigPostDraft draft;
  final bool submitting;

  GigPostWizardStep get step => GigPostWizardStep.values[stepIndex];

  GigPostWizardState copyWith({
    int? stepIndex,
    GigPostDraft? draft,
    bool? submitting,
  }) {
    return GigPostWizardState(
      stepIndex: stepIndex ?? this.stepIndex,
      draft: draft ?? this.draft,
      submitting: submitting ?? this.submitting,
    );
  }
}

class GigPostWizardController extends Notifier<GigPostWizardState> {
  @override
  GigPostWizardState build() => const GigPostWizardState();

  void reset() => state = const GigPostWizardState();

  void updateDraft(GigPostDraft draft) =>
      state = state.copyWith(draft: draft);

  bool get _categoryHasFields =>
      (categoryFieldSchema[state.draft.category] ?? const []).isNotEmpty;

  bool get canContinue {
    final draft = state.draft;
    switch (state.step) {
      case GigPostWizardStep.title:
        return draft.title.trim().isNotEmpty;
      case GigPostWizardStep.category:
        if (draft.category == null) return false;
        if (draft.category == GigCategory.other) {
          return draft.customCategory.trim().isNotEmpty;
        }
        return true;
      case GigPostWizardStep.location:
        return draft.serviceArea.trim().isNotEmpty;
      case GigPostWizardStep.pricing:
        return draft.pricingModel != null &&
            (draft.priceZarMinor ?? 0) > 0;
      case GigPostWizardStep.details:
        return draft.description.trim().isNotEmpty;
      case GigPostWizardStep.categoryFields:
      case GigPostWizardStep.portfolio: // optional in the skeleton
      case GigPostWizardStep.review:
        return true;
    }
  }

  void next() {
    var index = state.stepIndex + 1;
    if (GigPostWizardStep.values[index] ==
            GigPostWizardStep.categoryFields &&
        !_categoryHasFields) {
      index++;
    }
    if (index < GigPostWizardStep.values.length) {
      state = state.copyWith(stepIndex: index);
    }
  }

  bool back() {
    if (state.stepIndex == 0) return false;
    var index = state.stepIndex - 1;
    if (GigPostWizardStep.values[index] ==
            GigPostWizardStep.categoryFields &&
        !_categoryHasFields) {
      index--;
    }
    state = state.copyWith(stepIndex: index);
    return true;
  }

  void jumpToStep(GigPostWizardStep step) =>
      state = state.copyWith(stepIndex: step.index);

  Future<GigPost> submit() async {
    state = state.copyWith(submitting: true);
    try {
      return await ref
          .read(gigPostRepositoryProvider)
          .create(state.draft);
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  Future<void> saveDraft() =>
      ref.read(gigPostRepositoryProvider).saveDraft(state.draft);
}

final gigPostWizardProvider =
    NotifierProvider<GigPostWizardController, GigPostWizardState>(
        GigPostWizardController.new);
