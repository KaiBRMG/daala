import '../../../core/models/gig_category.dart';

enum LocationType { inPerson, online }

enum WhenType {
  flexible('Flexible'),
  today('Today'),
  thisWeek('This week'),
  onADate('On a date');

  const WhenType(this.label);

  final String label;
}

/// Data captured by the Create Gig Request Wizard (DESIGN.md §3.4).
class GigRequestDraft {
  const GigRequestDraft({
    this.title = '',
    this.category,
    this.customCategory = '',
    this.locationType = LocationType.inPerson,
    this.address = '',
    this.whenType,
    this.date,
    this.budgetZarMinor,
    this.description = '',
    this.photoCount = 0,
    this.categoryFields = const {},
  });

  final String title;
  final GigCategory? category;

  /// Free-text sub-field when [category] is [GigCategory.other].
  final String customCategory;
  final LocationType locationType;
  final String address;
  final WhenType? whenType;
  final DateTime? date;
  final int? budgetZarMinor;
  final String description;

  /// Mock photo picker — only the count is kept (placeholder tiles).
  final int photoCount;
  final Map<String, Object?> categoryFields;

  GigRequestDraft copyWith({
    String? title,
    GigCategory? category,
    String? customCategory,
    LocationType? locationType,
    String? address,
    WhenType? whenType,
    DateTime? date,
    int? budgetZarMinor,
    String? description,
    int? photoCount,
    Map<String, Object?>? categoryFields,
  }) {
    return GigRequestDraft(
      title: title ?? this.title,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      locationType: locationType ?? this.locationType,
      address: address ?? this.address,
      whenType: whenType ?? this.whenType,
      date: date ?? this.date,
      budgetZarMinor: budgetZarMinor ?? this.budgetZarMinor,
      description: description ?? this.description,
      photoCount: photoCount ?? this.photoCount,
      categoryFields: categoryFields ?? this.categoryFields,
    );
  }
}
