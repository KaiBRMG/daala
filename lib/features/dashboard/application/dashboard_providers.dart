import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_wallet_store.dart';
import '../data/mock_dashboard_repository.dart';
import '../domain/dashboard_gig.dart';
import '../domain/dashboard_repository.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) => MockDashboardRepository());

class DashboardTabNotifier extends Notifier<DashboardTab> {
  @override
  DashboardTab build() => DashboardTab.active;

  void set(DashboardTab tab) => state = tab;
}

final dashboardTabProvider =
    NotifierProvider<DashboardTabNotifier, DashboardTab>(
        DashboardTabNotifier.new);

final dashboardRowsProvider = FutureProvider.autoDispose
    .family<List<DashboardGig>, DashboardTab>((ref, tab) async {
  return ref.watch(dashboardRepositoryProvider).rowsFor(tab);
});

/// Available balance for the app-bar wallet-glance chip (shared through
/// core/mock — no cross-feature import of the wallet feature).
final walletGlanceProvider = Provider<int>(
    (ref) => ref.watch(mockWalletStoreProvider).availableZarMinor);
