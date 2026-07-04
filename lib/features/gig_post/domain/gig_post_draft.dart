import '../../../core/models/gig_category.dart';

/// Pricing models for a Gig Post (DESIGN.md §3.4 wizard deltas).
enum PricingModel {
  fixed('Fixed price'),
  from('From'),
  hourly('Hourly');

  const PricingModel(this.label);

  final String label;
}

/// Data captured by the Create Gig Post Wizard.
class GigPostDraft {
  const GigPostDraft({
    this.title = '',
    this.category,
    this.customCategory = '',
    this.serviceArea = '',
    this.pricingModel,
    this.priceZarMinor,
    this.description = '',
    this.portfolioCount = 0,
    this.categoryFields = const {},
  });

  final String title;
  final GigCategory? category;
  final String customCategory;
  final String serviceArea;
  final PricingModel? pricingModel;
  final int? priceZarMinor;
  final String description;

  /// Mock media picker — portfolio is optional in the skeleton.
  final int portfolioCount;
  final Map<String, Object?> categoryFields;

  GigPostDraft copyWith({
    String? title,
    GigCategory? category,
    String? customCategory,
    String? serviceArea,
    PricingModel? pricingModel,
    int? priceZarMinor,
    String? description,
    int? portfolioCount,
    Map<String, Object?>? categoryFields,
  }) {
    return GigPostDraft(
      title: title ?? this.title,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      serviceArea: serviceArea ?? this.serviceArea,
      pricingModel: pricingModel ?? this.pricingModel,
      priceZarMinor: priceZarMinor ?? this.priceZarMinor,
      description: description ?? this.description,
      portfolioCount: portfolioCount ?? this.portfolioCount,
      categoryFields: categoryFields ?? this.categoryFields,
    );
  }
}
