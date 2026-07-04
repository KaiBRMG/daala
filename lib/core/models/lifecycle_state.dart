/// Unified lifecycle enum for Gig Requests and Gig Posts (DESIGN.md §2.4).
///
/// Gig Request:  OPEN → OFFER_ACCEPTED → IN_ESCROW → IN_PROGRESS → COMPLETED
///               (+ EXPIRED, CANCELLED, DISPUTED → RESOLVED)
/// Gig Post:     ACTIVE → BOOKED → IN_ESCROW → IN_PROGRESS → COMPLETED
///               (+ PAUSED, CANCELLED, DISPUTED → RESOLVED)
///
/// [wireName] preserves the verbatim spec value — it will back Firestore in
/// later phases. [badgeLabel] is the verbatim badge copy from §2.4.
enum LifecycleState {
  open('OPEN', 'Open'),
  active('ACTIVE', 'Active'),
  offerAccepted('OFFER_ACCEPTED', 'Booked'),
  booked('BOOKED', 'Booked'),
  inEscrow('IN_ESCROW', 'In Escrow'),
  inProgress('IN_PROGRESS', 'In progress'),
  completed('COMPLETED', 'Completed'),
  disputed('DISPUTED', 'Disputed'),
  // TODO(spec): §2.4 badge table omits RESOLVED — rendered as status.neutral.
  resolved('RESOLVED', 'Resolved'),
  expired('EXPIRED', 'Expired'),
  cancelled('CANCELLED', 'Cancelled'),
  paused('PAUSED', 'Paused');

  const LifecycleState(this.wireName, this.badgeLabel);

  /// Verbatim enum value per DESIGN.md §2.4 (future Firestore value).
  final String wireName;

  /// Verbatim status-badge label per DESIGN.md §2.4.
  final String badgeLabel;
}
