import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';
import '../../../core/utils/debug_flags.dart';
import '../../../core/utils/mock_delay.dart';
import '../domain/dashboard_gig.dart';
import '../domain/dashboard_repository.dart';

/// Fixture rows per tab — ids line up with the booking (`b-*`) and gig
/// (`gr-*`) fixtures so taps land on real mock details.
class MockDashboardRepository implements DashboardRepository {
  static final Map<DashboardTab, List<DashboardGig>> _rows = {
    DashboardTab.active: [
      DashboardGig(
        id: 'row-b1',
        listingType: ListingType.gigRequest,
        title: 'Fix a leaking kitchen pipe',
        counterpartyName: 'Sipho Dlamini',
        statusEnum: LifecycleState.inProgress,
        amountZarMinor: 45000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadFlag: true,
        target: DashboardTarget.booking,
        targetId: 'b-1',
      ),
      DashboardGig(
        id: 'row-gr2',
        listingType: ListingType.gigRequest,
        title: 'Move a 2-bedroom flat to Bellville',
        statusEnum: LifecycleState.open,
        amountZarMinor: 125000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        target: DashboardTarget.gigRequestDetail,
        targetId: 'gr-2',
      ),
    ],
    DashboardTab.offers: [
      DashboardGig(
        id: 'row-offers-gr2',
        listingType: ListingType.gigRequest,
        title: 'Move a 2-bedroom flat to Bellville',
        counterpartyName: '4 Offers received',
        statusEnum: LifecycleState.open,
        amountZarMinor: 125000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        unreadFlag: true,
        target: DashboardTarget.reviewOffers,
        targetId: 'gr-2',
      ),
    ],
    DashboardTab.inEscrow: [
      DashboardGig(
        id: 'row-b2',
        listingType: ListingType.gigPost,
        title: 'Deep home cleaning, flats & houses',
        counterpartyName: 'Nomvula Khumalo',
        statusEnum: LifecycleState.inEscrow,
        amountZarMinor: 35000,
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        target: DashboardTarget.booking,
        targetId: 'b-2',
      ),
      DashboardGig(
        id: 'row-b3',
        listingType: ListingType.gigRequest,
        title: 'Garden cleanup and lawn mowing',
        counterpartyName: 'Lerato Nkosi',
        statusEnum: LifecycleState.disputed,
        amountZarMinor: 60000,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        target: DashboardTarget.booking,
        targetId: 'b-3',
      ),
    ],
    DashboardTab.completed: [
      DashboardGig(
        id: 'row-b4',
        listingType: ListingType.gigRequest,
        title: 'Maths tutoring for Grade 10 learner',
        counterpartyName: 'Ayesha Patel',
        statusEnum: LifecycleState.completed,
        amountZarMinor: 30000,
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        target: DashboardTarget.booking,
        targetId: 'b-4',
      ),
    ],
    DashboardTab.drafts: [
      DashboardGig(
        id: 'row-draft-1',
        listingType: ListingType.gigRequest,
        title: 'Paint the front gate (draft)',
        statusEnum: LifecycleState.cancelled,
        amountZarMinor: 0,
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        target: DashboardTarget.draftWizard,
        targetId: '',
      ),
    ],
  };

  @override
  Future<List<DashboardGig>> rowsFor(DashboardTab tab) async {
    await mockNetworkDelay();
    DebugFlags.maybeThrow();
    return DebugFlags.maybeEmpty(_rows[tab] ?? const []);
  }
}
