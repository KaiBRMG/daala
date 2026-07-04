import '../models/poster_summary.dart';
import 'mock_session.dart';

/// Shared poster/merchant/consumer fixtures. IDs are referenced across
/// feature fixtures (feed, details, offers, bookings, chat).
abstract final class MockPosters {
  static const PosterSummary me = PosterSummary(
    id: MockSession.userId,
    displayName: MockSession.displayName,
    ratingAvg: 4.6,
    reviewCount: 9,
    isVerified: false,
    memberSince: '2025',
  );

  static const PosterSummary merchantSipho = PosterSummary(
    id: 'm-1',
    displayName: 'Sipho Dlamini',
    ratingAvg: 4.8,
    reviewCount: 126,
    isVerified: true,
    memberSince: '2023',
    jobsCompleted: 87,
    completionRate: 98,
    responseTimeLabel: '~1 hour',
  );

  static const PosterSummary merchantLerato = PosterSummary(
    id: 'm-2',
    displayName: 'Lerato Nkosi',
    ratingAvg: 4.9,
    reviewCount: 64,
    isVerified: true,
    memberSince: '2024',
    jobsCompleted: 52,
    completionRate: 100,
    responseTimeLabel: '~30 minutes',
  );

  static const PosterSummary merchantJohan = PosterSummary(
    id: 'm-3',
    displayName: 'Johan van der Merwe',
    ratingAvg: 4.5,
    reviewCount: 38,
    isVerified: false,
    memberSince: '2024',
    jobsCompleted: 29,
    completionRate: 93,
    responseTimeLabel: '~3 hours',
  );

  static const PosterSummary merchantAyesha = PosterSummary(
    id: 'm-4',
    displayName: 'Ayesha Patel',
    ratingAvg: 4.7,
    reviewCount: 81,
    isVerified: true,
    memberSince: '2023',
    jobsCompleted: 66,
    completionRate: 97,
    responseTimeLabel: '~2 hours',
  );

  static const PosterSummary consumerNomvula = PosterSummary(
    id: 'c-1',
    displayName: 'Nomvula Khumalo',
    ratingAvg: 4.4,
    reviewCount: 12,
    isVerified: true,
    memberSince: '2024',
  );

  static const PosterSummary consumerDavid = PosterSummary(
    id: 'c-2',
    displayName: 'David Botha',
    ratingAvg: 4.2,
    reviewCount: 7,
    isVerified: false,
    memberSince: '2025',
  );

  static const PosterSummary consumerZanele = PosterSummary(
    id: 'c-3',
    displayName: 'Zanele Mthembu',
    ratingAvg: 4.9,
    reviewCount: 21,
    isVerified: true,
    memberSince: '2023',
  );

  static const List<PosterSummary> merchants = [
    merchantSipho,
    merchantLerato,
    merchantJohan,
    merchantAyesha,
  ];

  static PosterSummary? byId(String id) {
    for (final p in [me, consumerNomvula, consumerDavid, consumerZanele,
        ...merchants]) {
      if (p.id == id) return p;
    }
    return null;
  }
}
