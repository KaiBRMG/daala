import '../../../core/mock/mock_posters.dart';
import '../../../core/mock/mock_session.dart';
import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/conversation.dart';
import '../domain/messaging_repository.dart';

/// In-memory conversations. Thread ids follow `t-{posterId}` so "Message" /
/// "Enquire" CTAs elsewhere can open (or synthesise) a thread per party.
class MockMessagingRepository implements MessagingRepository {
  final Map<String, Conversation> _conversations = {
    't-m-1': Conversation(
      threadId: 't-m-1',
      counterparty: MockPosters.merchantSipho,
      gigRef: const GigRef(
        id: 'gr-1',
        type: ListingType.gigRequest,
        title: 'Fix a leaking kitchen pipe',
        amountZarMinor: 45000,
        statusEnum: LifecycleState.inProgress,
        bookingId: 'b-1',
      ),
      lastMessage: "I'll be there at 09:00 tomorrow with the parts.",
      lastTs: DateTime.now().subtract(const Duration(minutes: 20)),
      unreadCount: 2,
    ),
    't-m-2': Conversation(
      threadId: 't-m-2',
      counterparty: MockPosters.merchantLerato,
      gigRef: const GigRef(
        id: 'gp-2',
        type: ListingType.gigPost,
        title: 'Deep home cleaning, flats & houses',
        amountZarMinor: 35000,
        statusEnum: LifecycleState.inEscrow,
        bookingId: 'b-2',
      ),
      lastMessage: 'Thanks for booking! Does Saturday morning work?',
      lastTs: DateTime.now().subtract(const Duration(hours: 3)),
      unreadCount: 0,
    ),
    't-c-2': Conversation(
      threadId: 't-c-2',
      counterparty: MockPosters.consumerDavid,
      gigRef: const GigRef(
        id: 'gr-3',
        type: ListingType.gigRequest,
        title: 'Maths tutoring for Grade 10 learner',
        amountZarMinor: 30000,
        statusEnum: LifecycleState.open,
      ),
      lastMessage: 'Would Tuesday and Thursday afternoons suit you?',
      lastTs: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 1,
    ),
  };

  late final Map<String, List<Message>> _messages = {
    't-m-1': [
      Message(
        id: 'msg-1',
        senderId: MockSession.userId,
        text: 'Hi Sipho, thanks for the offer. When can you come?',
        sentAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Message(
        id: 'msg-2',
        senderId: 'm-1',
        text: 'Hi Thandi! I can do tomorrow morning if that works.',
        sentAt:
            DateTime.now().subtract(const Duration(hours: 4, minutes: 40)),
      ),
      Message(
        id: 'msg-3',
        senderId: MockSession.userId,
        text: 'Perfect. The leak is under the kitchen sink — I sent '
            'photos with the request.',
        sentAt:
            DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
      ),
      Message(
        id: 'msg-4',
        senderId: 'm-1',
        text: 'Saw them, looks like the trap joint. Easy fix.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Message(
        id: 'msg-5',
        senderId: 'm-1',
        text: "I'll be there at 09:00 tomorrow with the parts.",
        sentAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ],
    't-m-2': [
      Message(
        id: 'msg-6',
        senderId: 'm-2',
        text: 'Thanks for booking! Does Saturday morning work?',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ],
    't-c-2': [
      Message(
        id: 'msg-7',
        senderId: 'c-2',
        text: 'Would Tuesday and Thursday afternoons suit you?',
        sentAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
  };

  @override
  Future<List<Conversation>> conversations() async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    final list = _conversations.values.toList()
      ..sort((a, b) => b.lastTs.compareTo(a.lastTs));
    return DebugFlags.maybeEmpty(list);
  }

  @override
  Future<ChatThread> thread(String threadId) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    final conversation =
        _conversations[threadId] ?? _synthesise(threadId);
    return ChatThread(
      conversation: conversation,
      messages: List.unmodifiable(_messages[threadId] ?? const []),
    );
  }

  /// "Message"/"Enquire" can target a party we have no thread with yet —
  /// synthesise an empty one from the poster fixtures.
  Conversation _synthesise(String threadId) {
    final posterId = threadId.startsWith('t-')
        ? threadId.substring(2)
        : threadId;
    final poster = MockPosters.byId(posterId);
    if (poster == null) {
      throw StateError('Unknown thread: $threadId');
    }
    final conversation = Conversation(
      threadId: threadId,
      counterparty: poster,
      lastMessage: '',
      lastTs: DateTime.now(),
      unreadCount: 0,
    );
    _conversations[threadId] = conversation;
    return conversation;
  }

  @override
  Future<Message> send(
      {required String threadId, required String text}) async {
    await mockNetworkDelay();
    final message = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: MockSession.userId,
      text: text,
      sentAt: DateTime.now(),
    );
    _messages.putIfAbsent(threadId, () => []).add(message);
    return message;
  }
}
