import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'daala_button.dart';
import 'sticky_bottom_bar.dart';

/// Shared create-wizard step scaffold (DESIGN.md §3.4): close/back +
/// thin progress track + "Save & exit", one `h2` question, one focused
/// input group, sticky Continue.
class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    super.key,
    required this.stepIndex,
    required this.stepCount,
    required this.question,
    this.helper,
    required this.body,
    required this.continueLabel,
    this.continueEnabled = true,
    this.submitting = false,
    required this.onContinue,
    required this.onBack,
    required this.onSaveAndExit,
  });

  final int stepIndex;
  final int stepCount;
  final String question;
  final String? helper;
  final Widget body;
  final String continueLabel;
  final bool continueEnabled;
  final bool submitting;
  final VoidCallback onContinue;
  final VoidCallback onBack;
  final VoidCallback onSaveAndExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
              stepIndex == 0 ? Icons.close : Icons.arrow_back_ios_new,
              size: DaalaSizes.iconLg,
              color: DaalaColors.ink900),
          onPressed: onBack,
        ),
        title: _ProgressTrack(value: (stepIndex + 1) / stepCount),
        actions: [
          TextButton(
            onPressed: onSaveAndExit,
            child: Text('Save & exit',
                style: DaalaTextStyles.label
                    .copyWith(color: DaalaColors.brandGreen900)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          children: [
            const SizedBox(height: DaalaSpacing.s8),
            Text(question,
                style: DaalaTextStyles.h2
                    .copyWith(color: DaalaColors.ink900)),
            if (helper != null) ...[
              const SizedBox(height: DaalaSpacing.s8),
              Text(helper!,
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.ink500)),
            ],
            const SizedBox(height: DaalaSpacing.sectionGap),
            body,
          ],
        ),
      ),
      bottomNavigationBar: StickyBottomBar(
        child: DaalaButton(
          label: continueLabel,
          loading: submitting,
          onPressed: continueEnabled ? onContinue : null,
        ),
      ),
    );
  }
}

/// Thin 4 px progress track filled `brand.green.900`.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DaalaRadius.rPill),
      child: Container(
        height: DaalaSizes.progressTrackHeight,
        color: DaalaColors.borderSubtle,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          child: Container(color: DaalaColors.brandGreen900),
        ),
      ),
    );
  }
}
