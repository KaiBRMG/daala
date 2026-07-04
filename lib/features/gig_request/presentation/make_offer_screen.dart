import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_card.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/sticky_bottom_bar.dart';
import '../application/gig_request_providers.dart';

/// Make an Offer (DESIGN.md §3.5): amount + message, mock 15% fee preview.
class MakeOfferScreen extends ConsumerStatefulWidget {
  const MakeOfferScreen({super.key, required this.gigRequestId});

  final String gigRequestId;

  @override
  ConsumerState<MakeOfferScreen> createState() => _MakeOfferScreenState();
}

class _MakeOfferScreenState extends ConsumerState<MakeOfferScreen> {
  final _amount = TextEditingController();
  final _message = TextEditingController();
  bool _submitting = false;
  String? _amountError;
  String? _bannerError;

  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  int? get _amountZarMinor {
    final rand = int.tryParse(_amount.text.trim());
    return rand == null ? null : rand * 100;
  }

  Future<void> _submit() async {
    final amount = _amountZarMinor;
    setState(() {
      _bannerError = null;
      _amountError =
          (amount == null || amount <= 0) ? 'Enter an offer amount' : null;
    });
    if (_amountError != null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(offerActionsProvider).submitOffer(
            gigRequestId: widget.gigRequestId,
            amountZarMinor: amount!,
            message: _message.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Offer sent')));
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _bannerError = "Couldn't send your Offer. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(gigRequestProvider(widget.gigRequestId));
    final amount = _amountZarMinor;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Make an Offer',
                style: DaalaTextStyles.title
                    .copyWith(color: DaalaColors.ink900)),
            request.maybeWhen(
              data: (gig) => Text(gig.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.ink500)),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: request.when(
        loading: () => const Shimmer(
          child: Padding(
            padding: EdgeInsets.all(DaalaSpacing.screenH),
            child: Column(
              children: [
                ShimmerBox(height: 88, radius: DaalaRadius.rLg),
                SizedBox(height: DaalaSpacing.s24),
                ShimmerBox(height: DaalaSizes.inputHeight),
                SizedBox(height: DaalaSpacing.s24),
                ShimmerBox(height: 120),
              ],
            ),
          ),
        ),
        error: (_, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(gigRequestProvider(widget.gigRequestId))),
        data: (gig) => ListView(
          padding: const EdgeInsets.all(DaalaSpacing.screenH),
          children: [
            if (_bannerError != null) ...[
              Container(
                padding: const EdgeInsets.all(DaalaSpacing.s12),
                decoration: BoxDecoration(
                  color: DaalaColors.statusDisputeBg,
                  borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                ),
                child: Text(_bannerError!,
                    style: DaalaTextStyles.caption
                        .copyWith(color: DaalaColors.statusDispute)),
              ),
              const SizedBox(height: DaalaSpacing.s16),
            ],
            DaalaCard(
              child: Row(
                children: [
                  DaalaAvatar(
                      name: gig.poster.displayName,
                      size: DaalaSizes.avatarSm),
                  const SizedBox(width: DaalaSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gig.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DaalaTextStyles.title
                                .copyWith(color: DaalaColors.ink900)),
                        Text(
                          '${gig.poster.displayName} · Budget '
                          '${formatZar(gig.budgetZarMinor)}',
                          style: DaalaTextStyles.caption
                              .copyWith(color: DaalaColors.ink500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DaalaSpacing.sectionGap),
            DaalaInput(
              label: 'Your offer',
              hint: '0',
              controller: _amount,
              prefixText: 'R ',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textStyle: DaalaTextStyles.moneyMd
                  .copyWith(color: DaalaColors.ink900),
              errorText: _amountError,
              helperText:
                  "Consumer's budget: ${formatZar(gig.budgetZarMinor)}",
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: DaalaSpacing.s8),
            Text(
              'You receive after $platformFeePercent% platform fee: '
              '${formatZar(netAfterFeeZarMinor(amount ?? 0))}',
              style: DaalaTextStyles.caption
                  .copyWith(color: DaalaColors.ink500),
            ),
            const SizedBox(height: DaalaSpacing.sectionGap),
            DaalaInput(
              label: 'Message to Consumer',
              hint: 'Introduce yourself, say when you can start and '
                  'what your price includes.',
              controller: _message,
              maxLines: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: StickyBottomBar(
        child: DaalaButton(
          label: 'Submit Offer',
          loading: _submitting,
          onPressed: request.hasValue ? _submit : null,
        ),
      ),
    );
  }
}
