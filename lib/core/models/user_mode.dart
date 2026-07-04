/// A single Daala account operates in either mode — a lightweight context
/// switch, not a separate login (DESIGN.md §2.2).
enum UserMode {
  consumer('Get things done'),
  merchant('Earn money');

  const UserMode(this.intentLabel);

  final String intentLabel;
}

/// How the viewer relates to a listing — drives which CTA is shown.
enum ViewerRelationship { owner, merchant, other }
