import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/daala_avatar.dart';
import '../../../core/widgets/daala_input.dart';
import '../../../core/widgets/daala_list_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/messaging_providers.dart';
import '../domain/conversation.dart';

/// Messages list (DESIGN.md §3.9) — all gig-scoped conversations.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DaalaSpacing.screenH,
                  DaalaSpacing.s16, DaalaSpacing.screenH, DaalaSpacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Messages',
                      style: DaalaTextStyles.h1
                          .copyWith(color: DaalaColors.ink900)),
                  const SizedBox(height: DaalaSpacing.s12),
                  DaalaInput(
                    hint: 'Search conversations',
                    onChanged: (value) =>
                        setState(() => _filter = value.toLowerCase()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: conversations.when(
                loading: () => Shimmer(
                  child: ListView.builder(
                    itemCount: 8,
                    itemBuilder: (_, _) => const ListRowSkeleton(),
                  ),
                ),
                error: (_, _) => ErrorState(
                    onRetry: () =>
                        ref.invalidate(conversationsProvider)),
                data: (list) {
                  final filtered = _filter.isEmpty
                      ? list
                      : list
                          .where((c) =>
                              c.counterparty.displayName
                                  .toLowerCase()
                                  .contains(_filter) ||
                              (c.gigRef?.title.toLowerCase() ?? '')
                                  .contains(_filter))
                          .toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      headline: 'No messages yet',
                      subtext:
                          'Your conversations about gigs will appear here.',
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _ConversationRow(
                      conversation: filtered[i],
                      onTap: () => context.push(
                          RoutePaths.chatThread(filtered[i].threadId)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.conversation, required this.onTap});

  final Conversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DaalaSpacing.s16, vertical: DaalaSpacing.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DaalaAvatar(
                name: conversation.counterparty.displayName,
                size: DaalaSizes.avatarMd),
            const SizedBox(width: DaalaSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.counterparty.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DaalaTextStyles.title
                          .copyWith(color: DaalaColors.ink900)),
                  if (conversation.gigRef != null)
                    Text('Re: ${conversation.gigRef!.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DaalaTextStyles.caption
                            .copyWith(color: DaalaColors.ink500)),
                  const SizedBox(height: DaalaSpacing.s2),
                  Text(conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DaalaTextStyles.body
                          .copyWith(color: DaalaColors.ink700)),
                ],
              ),
            ),
            const SizedBox(width: DaalaSpacing.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatRelative(conversation.lastTs),
                    style: DaalaTextStyles.caption
                        .copyWith(color: DaalaColors.ink500)),
                if (conversation.unreadCount > 0) ...[
                  const SizedBox(height: DaalaSpacing.s4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DaalaSpacing.s8,
                        vertical: DaalaSpacing.s2),
                    decoration: BoxDecoration(
                      color: DaalaColors.accentOrange500,
                      borderRadius:
                          BorderRadius.circular(DaalaRadius.rPill),
                    ),
                    child: Text('${conversation.unreadCount}',
                        style: DaalaTextStyles.overline
                            .copyWith(color: DaalaColors.onBrand)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
