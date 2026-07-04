import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/models/poster_summary.dart';

/// The gig a conversation is scoped to (DESIGN.md §3.9 gig-context header).
class GigRef {
  const GigRef({
    required this.id,
    required this.type,
    required this.title,
    required this.amountZarMinor,
    required this.statusEnum,
    this.hasThumbnail = false,
    this.bookingId,
  });

  final String id;
  final ListingType type;
  final String title;
  final int amountZarMinor;
  final LifecycleState statusEnum;
  final bool hasThumbnail;

  /// Set when the conversation is about an active Booking — "View gig"
  /// then routes to the Booking instead of the listing.
  final String? bookingId;
}

class Conversation {
  const Conversation({
    required this.threadId,
    required this.counterparty,
    this.gigRef,
    required this.lastMessage,
    required this.lastTs,
    required this.unreadCount,
  });

  final String threadId;
  final PosterSummary counterparty;

  /// Null only for freshly-synthesised enquiry threads with no gig yet.
  final GigRef? gigRef;
  final String lastMessage;
  final DateTime lastTs;
  final int unreadCount;
}

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
}

/// A loaded thread: conversation header + messages (oldest first).
class ChatThread {
  const ChatThread({required this.conversation, required this.messages});

  final Conversation conversation;
  final List<Message> messages;
}
