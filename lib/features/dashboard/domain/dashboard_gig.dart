import '../../../core/models/lifecycle_state.dart';
import '../../../core/models/listing_type.dart';

/// Dashboard segmented tabs (DESIGN.md §3.8).
enum DashboardTab {
  active('Active', 'active'),
  offers('Offers', 'offers'),
  inEscrow('In Escrow', 'in-escrow'),
  completed('Completed', 'completed'),
  drafts('Drafts', 'drafts');

  const DashboardTab(this.label, this.queryValue);

  final String label;

  /// `?tab=` query value (route table §2.3).
  final String queryValue;

  static DashboardTab fromQuery(String? value) =>
      DashboardTab.values.firstWhere((tab) => tab.queryValue == value,
          orElse: () => DashboardTab.active);
}

/// Where tapping a row goes — routing resolved by state (§3.8).
enum DashboardTarget {
  gigRequestDetail,
  gigPostDetail,
  reviewOffers,
  booking,
  draftWizard,
}

/// One row in Dashboard / My Gigs (DESIGN.md §3.8 data requirements).
class DashboardGig {
  const DashboardGig({
    required this.id,
    required this.listingType,
    required this.title,
    this.counterpartyName,
    required this.statusEnum,
    required this.amountZarMinor,
    required this.updatedAt,
    this.unreadFlag = false,
    required this.target,
    required this.targetId,
  });

  final String id;
  final ListingType listingType;
  final String title;
  final String? counterpartyName;
  final LifecycleState statusEnum;
  final int amountZarMinor;
  final DateTime updatedAt;
  final bool unreadFlag;
  final DashboardTarget target;

  /// Id used by [target] (gig id or booking id).
  final String targetId;
}
