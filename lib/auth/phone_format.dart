/// Phone number entry helpers for the Daala sign-in flow.
///
/// Daala launches in South Africa, so `+27` is the default and the picker
/// carries only the SADC neighbours a cross-border tasker might use. Shipping a
/// ~250-country dataset to a data-light audience buys nothing, and a narrow
/// list keeps the Firebase Auth SMS region policy tight (see CLAUDE.md § Phase 2
/// operations) — the cheapest available defence against SMS toll fraud.
library;

import 'package:flutter/services.dart';

/// One dialling region offered in the country picker.
class DialRegion {
  const DialRegion({
    required this.iso,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.nationalLength,
    required this.groups,
  });

  /// ISO 3166-1 alpha-2 code (`ZA`).
  final String iso;
  final String name;

  /// Dialling prefix without the `+` (`27`).
  final String dialCode;

  /// Flag emoji, rendered by the platform font.
  final String flag;

  /// Digits expected after the trunk `0` is stripped (`823456789` → 9).
  final int nationalLength;

  /// Display grouping of those digits (`[2, 3, 4]` → `82 345 6789`).
  final List<int> groups;

  String get display => '+$dialCode';
}

/// South Africa — the default selection and the launch market.
const DialRegion kDefaultRegion = DialRegion(
  iso: 'ZA',
  name: 'South Africa',
  dialCode: '27',
  flag: '🇿🇦',
  nationalLength: 9,
  groups: [2, 3, 4],
);

/// The regions Daala accepts at launch. South Africa leads; the rest are SADC
/// neighbours. Keep this list and the Firebase console's SMS region allow-list
/// in sync — a region here that is blocked there fails at "Send Code".
const List<DialRegion> kDialRegions = [
  kDefaultRegion,
  DialRegion(
    iso: 'NA',
    name: 'Namibia',
    dialCode: '264',
    flag: '🇳🇦',
    nationalLength: 9,
    groups: [2, 3, 4],
  ),
  DialRegion(
    iso: 'BW',
    name: 'Botswana',
    dialCode: '267',
    flag: '🇧🇼',
    nationalLength: 8,
    groups: [2, 3, 3],
  ),
  DialRegion(
    iso: 'ZW',
    name: 'Zimbabwe',
    dialCode: '263',
    flag: '🇿🇼',
    nationalLength: 9,
    groups: [2, 3, 4],
  ),
  DialRegion(
    iso: 'LS',
    name: 'Lesotho',
    dialCode: '266',
    flag: '🇱🇸',
    nationalLength: 8,
    groups: [4, 4],
  ),
  DialRegion(
    iso: 'SZ',
    name: 'Eswatini',
    dialCode: '268',
    flag: '🇸🇿',
    nationalLength: 8,
    groups: [4, 4],
  ),
  DialRegion(
    iso: 'MZ',
    name: 'Mozambique',
    dialCode: '258',
    flag: '🇲🇿',
    nationalLength: 9,
    groups: [2, 3, 4],
  ),
];

/// Resolves a device locale country code to a supported region, falling back to
/// South Africa. Used to preselect the picker on first launch.
DialRegion regionForCountryCode(String? isoCode) {
  if (isoCode == null) return kDefaultRegion;
  final upper = isoCode.toUpperCase();
  for (final region in kDialRegions) {
    if (region.iso == upper) return region;
  }
  return kDefaultRegion;
}

/// Strips everything that is not a digit, then drops the national trunk prefix.
///
/// South Africans write their number as `082 345 6789`; E.164 needs
/// `+27 82 345 6789`. Silently eating that leading `0` is the single most
/// valuable normalisation in this flow — typing it is muscle memory, and an
/// un-stripped `0` produces an invalid number Firebase rejects with an opaque
/// error.
String normaliseNationalDigits(String raw, DialRegion region) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');

  // A pasted international number: drop a leading dial code if present.
  if (digits.length > region.nationalLength &&
      digits.startsWith(region.dialCode)) {
    digits = digits.substring(region.dialCode.length);
  }
  // Trunk prefix.
  while (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length > region.nationalLength) {
    digits = digits.substring(0, region.nationalLength);
  }
  return digits;
}

/// Groups normalised digits for display: `823456789` → `82 345 6789`.
String formatNationalDigits(String digits, DialRegion region) {
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  var index = 0;
  for (final size in region.groups) {
    if (index >= digits.length) break;
    if (index > 0) buffer.write(' ');
    final end = (index + size).clamp(0, digits.length);
    buffer.write(digits.substring(index, end));
    index = end;
  }
  if (index < digits.length) buffer.write(' ${digits.substring(index)}');
  return buffer.toString();
}

/// Builds the E.164 string Firebase Auth expects: `+27823456789`.
String toE164(String nationalDigits, DialRegion region) =>
    '+${region.dialCode}$nationalDigits';

/// Renders an E.164 number back for display: `+27 82 345 6789`.
String formatE164ForDisplay(String e164) {
  for (final region in kDialRegions) {
    final prefix = '+${region.dialCode}';
    if (e164.startsWith(prefix)) {
      return '$prefix ${formatNationalDigits(e164.substring(prefix.length), region)}';
    }
  }
  return e164;
}

/// True when the entered number has the full national length for its region.
bool isCompleteNumber(String nationalDigits, DialRegion region) =>
    nationalDigits.length == region.nationalLength;

/// [TextInputFormatter] that normalises and groups as the user types, keeping
/// the caret at the end. The field is numeric-only, so caret-in-the-middle
/// editing is not a case worth the complexity here.
class NationalPhoneFormatter extends TextInputFormatter {
  NationalPhoneFormatter(this.region);

  final DialRegion region;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = normaliseNationalDigits(newValue.text, region);
    final text = formatNationalDigits(digits, region);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Loose email shape check for enabling the "Continue" button.
///
/// Deliberately permissive: the authoritative verdict is whether the sign-in
/// link arrives. Over-strict client regexes reject valid addresses and are a
/// classic accessibility failure.
bool looksLikeEmail(String value) {
  final trimmed = value.trim();
  final at = trimmed.indexOf('@');
  if (at <= 0 || at != trimmed.lastIndexOf('@')) return false;
  final domain = trimmed.substring(at + 1);
  return domain.contains('.') &&
      !domain.startsWith('.') &&
      !domain.endsWith('.') &&
      !trimmed.contains(' ');
}
