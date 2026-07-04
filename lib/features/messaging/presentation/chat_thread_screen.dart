import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/format_zar.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/media_placeholder.dart';
import '../../../core/widgets/shimmer.dart';
import '../../../core/widgets/status_badge.dart';
import '../application/messaging_providers.dart';
import '../domain/conversation.dart';

/// Chat Thread (DESIGN.md §3.9) — gig-context header, bubbles, composer
/// with optimistic append.
class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ChatThreadScreen> createState() =>
      _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _composer = TextEditingController();
  final List<Message> _optimistic = [];
  bool _canSend = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _openGig(GigRef gigRef) {
    if (gigRef.bookingId != null) {
      context.push(RoutePaths.booking(gigRef.bookingId!));
    } else if (gigRef.type == ListingType.gigRequest) {
      context.push(RoutePaths.gigRequest(gigRef.id));
    } else {
      context.push(RoutePaths.gigPost(gigRef.id));
    }
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _optimistic.add(Message(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        senderId: MockSession.userId,
        text: text,
        sentAt: DateTime.now(),
      ));
      _composer.clear();
      _canSend = false;
    });
    await ref
        .read(messagingRepositoryProvider)
        .send(threadId: widget.threadId, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(chatThreadProvider(widget.threadId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
        titleSpacing: 0,
        title: thread.maybeWhen(
          data: (data) => Row(
            children: [
              DaalaAvatar(
                  name: data.conversation.counterparty.displayName,
                  size: DaalaSizes.avatarSm),
              const SizedBox(width: DaalaSpacing.s8),
              Expanded(
                child: Text(
                  data.conversation.counterparty.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DaalaTextStyles.title
                      .copyWith(color: DaalaColors.ink900),
                ),
              ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          thread.maybeWhen(
            data: (data) => data.conversation.gigRef == null
                ? const SizedBox.shrink()
                : TextButton(
                    onPressed: () =>
                        _openGig(data.conversation.gigRef!),
                    child: Text('View gig',
                        style: DaalaTextStyles.label.copyWith(
                            color: DaalaColors.brandGreen900)),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: thread.when(
        loading: () => const _ThreadSkeleton(),
        error: (_, _) => ErrorState(
            onRetry: () =>
                ref.invalidate(chatThreadProvider(widget.threadId))),
        data: (data) {
          final messages = [...data.messages, ..._optimistic];
          return Column(
            children: [
              if (data.conversation.gigRef != null)
                _GigContextHeader(
                  gigRef: data.conversation.gigRef!,
                  onTap: () => _openGig(data.conversation.gigRef!),
                ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'Say hello to '
                          '${data.conversation.counterparty.displayName} 👋',
                          style: DaalaTextStyles.body
                              .copyWith(color: DaalaColors.ink500),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding:
                            const EdgeInsets.all(DaalaSpacing.screenH),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final index = messages.length - 1 - i;
                          final message = messages[index];
                          final isOwn =
                              message.senderId == MockSession.userId;
                          final lastOfRun =
                              index == messages.length - 1 ||
                                  messages[index + 1].senderId !=
                                      message.senderId;
                          return _Bubble(
                              message: message,
                              isOwn: isOwn,
                              showTimestamp: lastOfRun);
                        },
                      ),
              ),
              _Composer(
                controller: _composer,
                canSend: _canSend,
                onChanged: (value) => setState(
                    () => _canSend = value.trim().isNotEmpty),
                onSend: _send,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Pinned gig context: thumbnail · title · amount · status badge.
class _GigContextHeader extends StatelessWidget {
  const _GigContextHeader({required this.gigRef, required this.onTap});

  final GigRef gigRef;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DaalaColors.bgSecondary,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s12),
          child: Row(
            children: [
              const MediaPlaceholder(
                  width: DaalaSizes.leadingIconCircle,
                  height: DaalaSizes.leadingIconCircle,
                  radius: DaalaRadius.rSm),
              const SizedBox(width: DaalaSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gigRef.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DaalaTextStyles.label
                            .copyWith(color: DaalaColors.ink900)),
                    Text(formatZar(gigRef.amountZarMinor),
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500)),
                  ],
                ),
              ),
              const SizedBox(width: DaalaSpacing.s8),
              StatusBadge(state: gigRef.statusEnum),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.isOwn,
    required this.showTimestamp,
  });

  final Message message;
  final bool isOwn;
  final bool showTimestamp;

  @override
  Widget build(BuildContext context) {
    // Own bubbles: green fill, tail corner tightened (rSm bottom-right).
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(DaalaRadius.rLg),
      topRight: const Radius.circular(DaalaRadius.rLg),
      bottomLeft: Radius.circular(
          isOwn ? DaalaRadius.rLg : DaalaRadius.rSm),
      bottomRight: Radius.circular(
          isOwn ? DaalaRadius.rSm : DaalaRadius.rLg),
    );
    return Column(
      crossAxisAlignment:
          isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: DaalaSpacing.s4),
          padding: const EdgeInsets.symmetric(
              horizontal: DaalaSpacing.s12, vertical: DaalaSpacing.s8),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: isOwn
                ? DaalaColors.brandGreen900
                : DaalaColors.bgSecondary,
            borderRadius: radius,
          ),
          child: Text(
            message.text,
            style: DaalaTextStyles.body.copyWith(
                color:
                    isOwn ? DaalaColors.onBrand : DaalaColors.ink900),
          ),
        ),
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.only(bottom: DaalaSpacing.s12),
            child: Text(formatTime(message.sentAt),
                style: DaalaTextStyles.caption
                    .copyWith(color: DaalaColors.ink500)),
          ),
      ],
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.canSend,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DaalaColors.bgPrimary,
        boxShadow: DaalaElevation.e2,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(DaalaSpacing.s8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add,
                    color: DaalaColors.ink500, size: DaalaSizes.iconLg),
                // TODO(spec): attachment picker deferred to Phase 5.
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  minLines: 1,
                  maxLines: 4,
                  style: DaalaTextStyles.body
                      .copyWith(color: DaalaColors.ink900),
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: DaalaTextStyles.body
                        .copyWith(color: DaalaColors.ink300),
                    filled: true,
                    fillColor: DaalaColors.bgSecondary,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: DaalaSpacing.s16,
                        vertical: DaalaSpacing.s8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DaalaRadius.rPill),
                      borderSide: const BorderSide(
                          color: DaalaColors.borderDefault,
                          width: DaalaSizes.borderWidth),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(DaalaRadius.rPill),
                      borderSide: const BorderSide(
                          color: DaalaColors.brandGreen900,
                          width: DaalaSizes.borderWidthFocus),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: DaalaSpacing.s8),
              Material(
                color: canSend
                    ? DaalaColors.accentOrange500
                    : DaalaColors.borderDefault,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: canSend ? onSend : null,
                  child: const SizedBox(
                    width: DaalaSizes.touchTarget,
                    height: DaalaSizes.touchTarget,
                    child: Icon(Icons.send,
                        color: DaalaColors.onBrand,
                        size: DaalaSizes.iconMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadSkeleton extends StatelessWidget {
  const _ThreadSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: Padding(
        padding: EdgeInsets.all(DaalaSpacing.screenH),
        child: Column(
          children: [
            ShimmerBox(height: DaalaSizes.listRowMinHeight),
            SizedBox(height: DaalaSpacing.s24),
            Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBox(
                  width: 220, height: 44, radius: DaalaRadius.rLg),
            ),
            SizedBox(height: DaalaSpacing.s12),
            Align(
              alignment: Alignment.centerRight,
              child: ShimmerBox(
                  width: 180, height: 44, radius: DaalaRadius.rLg),
            ),
            SizedBox(height: DaalaSpacing.s12),
            Align(
              alignment: Alignment.centerLeft,
              child: ShimmerBox(
                  width: 240, height: 44, radius: DaalaRadius.rLg),
            ),
          ],
        ),
      ),
    );
  }
}
