import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_messaging_repository.dart';
import '../domain/conversation.dart';
import '../domain/messaging_repository.dart';

final messagingRepositoryProvider =
    Provider<MessagingRepository>((ref) => MockMessagingRepository());

final conversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) async {
  return ref.watch(messagingRepositoryProvider).conversations();
});

final chatThreadProvider = FutureProvider.autoDispose
    .family<ChatThread, String>((ref, threadId) async {
  return ref.watch(messagingRepositoryProvider).thread(threadId);
});
