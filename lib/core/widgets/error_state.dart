import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'daala_button.dart';

/// Standard error state (DESIGN.md §3 global conventions).
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.detail = 'Please check your connection and try again.',
    required this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String title;
  final String detail;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DaalaSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: DaalaSizes.emptyStateIcon,
                color: DaalaColors.statusDispute),
            const SizedBox(height: DaalaSpacing.s16),
            Text(
              title,
              style:
                  DaalaTextStyles.title.copyWith(color: DaalaColors.ink900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DaalaSpacing.s8),
            Text(
              detail,
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DaalaSpacing.s24),
            DaalaButton(
              label: retryLabel,
              variant: DaalaButtonVariant.secondary,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
