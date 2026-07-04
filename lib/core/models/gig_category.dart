/// Gig categories with an "Other/Custom" fallback (CLAUDE.md vocabulary).
enum GigCategory {
  plumbing('Plumbing'),
  electrical('Electrical'),
  gardening('Gardening'),
  tutoring('Tutoring'),
  cleaning('Cleaning'),
  moving('Moving'),
  other('Other');

  const GigCategory(this.label);

  final String label;
}
