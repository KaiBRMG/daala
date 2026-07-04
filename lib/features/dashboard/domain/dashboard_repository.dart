import 'dashboard_gig.dart';

/// Dashboard repository interface — mocked in Phase 1; real-time
/// Firestore streams arrive in Phase 4.
abstract class DashboardRepository {
  Future<List<DashboardGig>> rowsFor(DashboardTab tab);
}
