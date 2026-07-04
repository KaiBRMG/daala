import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_feed_store.dart';
import '../../../core/mock/mock_session.dart';
import '../../../core/models/user_mode.dart';
import '../data/mock_gig_post_repository.dart';
import '../domain/gig_post.dart';
import '../domain/gig_post_repository.dart';

final gigPostRepositoryProvider = Provider<GigPostRepository>(
    (ref) => MockGigPostRepository(ref.watch(mockFeedStoreProvider)));

final gigPostProvider =
    FutureProvider.autoDispose.family<GigPost, String>((ref, id) async {
  return ref.watch(gigPostRepositoryProvider).getById(id);
});

/// Owner sees "Edit Gig Post"; a Consumer sees Enquire/Book
/// (DESIGN.md §3.3).
ViewerRelationship gigPostViewerRelationship(
    MockSession session, GigPost post) {
  if (post.merchant.id == MockSession.userId) {
    return ViewerRelationship.owner;
  }
  return session.mode == UserMode.consumer
      ? ViewerRelationship.other
      : ViewerRelationship.merchant;
}
