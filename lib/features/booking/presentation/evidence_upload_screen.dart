import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/booking_providers.dart';

/// Upload completion evidence (DESIGN.md §2.1) — mock picker: each add
/// appends a placeholder photo to the Booking.
class EvidenceUploadScreen extends ConsumerStatefulWidget {
  const EvidenceUploadScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<EvidenceUploadScreen> createState() =>
      _EvidenceUploadScreenState();
}

class _EvidenceUploadScreenState
    extends ConsumerState<EvidenceUploadScreen> {
  bool _adding = false;

  Future<void> _addPhoto() async {
    setState(() => _adding = true);
    await ref.read(bookingActionsProvider).addEvidence(widget.bookingId);
    if (mounted) setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Upload evidence',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: booking.when(
        loading: () => const Shimmer(
          child: Padding(
            padding: EdgeInsets.all(DaalaSpacing.screenH),
            child: Row(
              children: [
                ShimmerBox(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
                SizedBox(width: DaalaSpacing.s8),
                ShimmerBox(
                    width: DaalaSizes.galleryTile,
                    height: DaalaSizes.galleryTile),
              ],
            ),
          ),
        ),
        error: (_, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(bookingProvider(widget.bookingId))),
        data: (data) => data.evidenceCount == 0
            ? const EmptyState(
                icon: Icons.photo_camera_outlined,
                headline: 'No evidence yet',
                subtext:
                    'Add photos of the completed work to protect both '
                    'parties.',
              )
            : ListView(
                padding: const EdgeInsets.all(DaalaSpacing.screenH),
                children: [
                  Text(data.gigTitle,
                      style: DaalaTextStyles.h3
                          .copyWith(color: DaalaColors.ink900)),
                  const SizedBox(height: DaalaSpacing.s16),
                  Wrap(
                    spacing: DaalaSpacing.s8,
                    runSpacing: DaalaSpacing.s8,
                    children: [
                      for (var i = 0; i < data.evidenceCount; i++)
                        const MediaPlaceholder(
                            width: DaalaSizes.galleryTile,
                            height: DaalaSizes.galleryTile),
                    ],
                  ),
                ],
              ),
      ),
      bottomNavigationBar: StickyBottomBar(
        child: Row(
          children: [
            Expanded(
              child: DaalaButton(
                label: 'Add photo',
                variant: DaalaButtonVariant.secondary,
                loading: _adding,
                onPressed: booking.hasValue ? _addPhoto : null,
              ),
            ),
            const SizedBox(width: DaalaSpacing.s12),
            Expanded(
              child: DaalaButton(
                  label: 'Done', onPressed: () => context.pop()),
            ),
          ],
        ),
      ),
    );
  }
}
