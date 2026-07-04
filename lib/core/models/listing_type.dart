/// The two listing kinds in Daala's fixed vocabulary.
///
/// A **Gig Post** is a Merchant-led listing advertising a service.
/// A **Gig Request** is a Consumer-led listing for a task to be done.
enum ListingType {
  gigRequest('REQUEST'),
  gigPost('SERVICE');

  const ListingType(this.tagLabel);

  /// Type-tag pill copy on GigCard (DESIGN.md §3.1).
  final String tagLabel;
}
