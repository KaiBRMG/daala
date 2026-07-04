import 'conversation.dart';

/// Messaging repository interface — mocked in Phase 1; Firestore-backed
/// real-time chat arrives in Phase 5.
abstract class MessagingRepository {
  Future<List<Conversation>> conversations();

  Future<ChatThread> thread(String threadId);

  Future<Message> send({required String threadId, required String text});
}
