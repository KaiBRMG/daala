import 'gig_category.dart';

enum CategoryFieldType { toggle, text }

/// One category-specific wizard field, rendered from a category schema
/// (DESIGN.md §3.4 step 7). "Other" has no schema and the step is skipped.
class CategoryFieldSpec {
  const CategoryFieldSpec({
    required this.key,
    required this.label,
    required this.type,
    this.helper,
  });

  final String key;
  final String label;
  final CategoryFieldType type;
  final String? helper;
}

/// Mock category schema for Phase 1.
const Map<GigCategory, List<CategoryFieldSpec>> categoryFieldSchema = {
  GigCategory.plumbing: [
    CategoryFieldSpec(
        key: 'emergency',
        label: 'Emergency call-out?',
        type: CategoryFieldType.toggle),
  ],
  GigCategory.electrical: [
    CategoryFieldSpec(
        key: 'cocRequired',
        label: 'Certificate of Compliance required?',
        type: CategoryFieldType.toggle),
  ],
  GigCategory.gardening: [
    CategoryFieldSpec(
        key: 'toolsSupplied',
        label: 'Tools supplied?',
        type: CategoryFieldType.toggle),
  ],
  GigCategory.tutoring: [
    CategoryFieldSpec(
        key: 'subject', label: 'Subject', type: CategoryFieldType.text),
    CategoryFieldSpec(
        key: 'level',
        label: 'Level',
        type: CategoryFieldType.text,
        helper: 'e.g. Grade 10, first-year university'),
  ],
  GigCategory.cleaning: [
    CategoryFieldSpec(
        key: 'homeSize',
        label: 'Home size',
        type: CategoryFieldType.text,
        helper: 'e.g. 2-bedroom flat'),
  ],
  GigCategory.moving: [
    CategoryFieldSpec(
        key: 'volume',
        label: 'Approximate volume / large items',
        type: CategoryFieldType.text),
  ],
};
