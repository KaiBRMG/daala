import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/models/poster_summary.dart';
import '../../../core/models/user_mode.dart';

/// One step in the Booking lifecycle timeline (DESIGN.md §3.7):
/// Agreed → Funds in Escrow → In Progress → Completed → Released.
class BookingTimelineStep {
  const BookingTimelineStep({
    required this.label,
    required this.done,
    required this.current,
  });

  final String label;
  final bool done;
  final bool current;
}

/// A confirmed engagement — the single source of truth for an agreed job
/// (DESIGN.md §3.7 data requirements).
class Booking {
  const Booking({
    required this.id,
    required this.gigTitle,
    required this.listingType,
    required this.amountZarMinor,
    required this.lifecycleState,
    required this.counterparty,
    required this.evidenceCount,
    required this.viewerRole,
  });

  final String id;
  final String gigTitle;
  final ListingType listingType;
  final int amountZarMinor;
  final LifecycleState lifecycleState;
  final PosterSummary counterparty;

  /// `evidence[]` — placeholder tiles in Phase 1.
  final int evidenceCount;

  /// Which party the viewer is (consumer|merchant).
  final UserMode viewerRole;

  static const List<String> timelineLabels = [
    'Agreed',
    'Funds in Escrow',
    'In Progress',
    'Completed',
    'Released',
  ];

  /// Derives the timeline from the lifecycle state.
  List<BookingTimelineStep> get timeline {
    final currentIndex = switch (lifecycleState) {
      LifecycleState.offerAccepted || LifecycleState.booked => 0,
      LifecycleState.inEscrow => 1,
      LifecycleState.inProgress ||
      LifecycleState.disputed =>
        2,
      LifecycleState.completed || LifecycleState.resolved => 4,
      _ => 0,
    };
    return [
      for (var i = 0; i < timelineLabels.length; i++)
        BookingTimelineStep(
          label: timelineLabels[i],
          done: i < currentIndex ||
              (i == currentIndex &&
                  lifecycleState == LifecycleState.completed),
          current: i == currentIndex,
        ),
    ];
  }

  Booking copyWith({LifecycleState? lifecycleState, int? evidenceCount}) {
    return Booking(
      id: id,
      gigTitle: gigTitle,
      listingType: listingType,
      amountZarMinor: amountZarMinor,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      counterparty: counterparty,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      viewerRole: viewerRole,
    );
  }
}

class BookingNotFoundException implements Exception {
  const BookingNotFoundException(this.id);

  final String id;
}
