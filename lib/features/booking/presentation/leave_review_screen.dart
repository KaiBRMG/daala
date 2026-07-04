import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/booking_providers.dart';

/// Leave Review (DESIGN.md §3.13): large 5-star selector, optional
/// comment, optional photo.
class LeaveReviewScreen extends ConsumerStatefulWidget {
  const LeaveReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<LeaveReviewScreen> createState() =>
      _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  final _comment = TextEditingController();
  int _rating = 0;
  bool _hasPhoto = false;
  bool _submitting = false;
  String? _ratingError;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() =>
        _ratingError = _rating == 0 ? 'Please choose a rating' : null);
    if (_ratingError != null) return;

    setState(() => _submitting = true);
    await ref.read(bookingActionsProvider).submitReview(
          bookingId: widget.bookingId,
          rating: _rating,
          comment: _comment.text.trim(),
          hasPhoto: _hasPhoto,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Review submitted')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Text('Leave Review',
            style:
                DaalaTextStyles.title.copyWith(color: DaalaColors.ink900)),
      ),
      body: booking.when(
        loading: () => const Shimmer(
          child: Padding(
            padding: EdgeInsets.all(DaalaSpacing.screenH),
            child: Column(
              children: [
                ShimmerBox(height: 72, radius: DaalaRadius.rLg),
                SizedBox(height: DaalaSpacing.s24),
                ShimmerBox(height: DaalaSpacing.s32),
                SizedBox(height: DaalaSpacing.s24),
                ShimmerBox(height: 120),
              ],
            ),
          ),
        ),
        error: (_, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(bookingProvider(widget.bookingId))),
        data: (data) => ListView(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          children: [
            Row(
              children: [
                DaalaAvatar(
                    name: data.counterparty.displayName,
                    size: DaalaSizes.avatarLg),
                const SizedBox(width: DaalaSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How was working with '
                          '${data.counterparty.displayName}?',
                          style: DaalaTextStyles.h3
                              .copyWith(color: DaalaColors.ink900)),
                      const SizedBox(height: DaalaSpacing.s4),
                      Text(data.gigTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DaalaTextStyles.caption
                              .copyWith(color: DaalaColors.ink500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DaalaSpacing.s32),
            Center(
              child: StarRating(
                rating: _rating,
                size: DaalaSpacing.s40,
                onChanged: (value) => setState(() => _rating = value),
              ),
            ),
            if (_ratingError != null) ...[
              const SizedBox(height: DaalaSpacing.s8),
              Center(
                child: Text(_ratingError!,
                    style: DaalaTextStyles.caption
                        .copyWith(color: DaalaColors.statusDispute)),
              ),
            ],
            const SizedBox(height: DaalaSpacing.s32),
            DaalaInput(
              label: 'Comment (optional)',
              hint: 'Share what went well or what could improve.',
              controller: _comment,
              maxLines: 5,
            ),
            const SizedBox(height: DaalaSpacing.s24),
            Text('Photo (optional)',
                style: DaalaTextStyles.caption
                    .copyWith(color: DaalaColors.ink500)),
            const SizedBox(height: DaalaSpacing.s8),
            Row(
              children: [
                if (_hasPhoto) ...[
                  const MediaPlaceholder(
                      width: DaalaSizes.galleryTile,
                      height: DaalaSizes.galleryTile),
                  const SizedBox(width: DaalaSpacing.s8),
                ],
                if (!_hasPhoto)
                  InkWell(
                    borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                    onTap: () => setState(() => _hasPhoto = true),
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
        ),
      ),
      bottomNavigationBar: StickyBottomBar(
        child: DaalaButton(
          label: 'Submit review',
          loading: _submitting,
          onPressed: booking.hasValue ? _submit : null,
        ),
      ),
    );
  }
}
