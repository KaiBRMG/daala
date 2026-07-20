/// South African Rand formatting — the single money helper for the app.
///
/// Amounts are stored as integer **minor units** (cents) and rendered through
/// [formatZar], per the CLAUDE.md `*ZarMinor` convention: `R1 250`, `R450`,
/// `R37.50`. The symbol is always `R`, prefixed; thousands are grouped with a
/// non-breaking space so a price never wraps mid-number. No other currency
/// symbol appears anywhere in Daala.
library;

/// Formats [minorUnits] (cents) as a Rand string.
///
/// - [cents] forces two decimal places (`R37.50`); when false, whole amounts
///   render without decimals (`R65`) and fractional amounts keep them.
/// - [signed] prefixes an explicit `+`/`-` (for transaction lists); otherwise
///   only negatives are signed.
String formatZar(int minorUnits, {bool cents = false, bool signed = false}) {
  final negative = minorUnits < 0;
  final abs = minorUnits.abs();
  final rand = abs ~/ 100;
  final remainder = abs % 100;

  final buffer = StringBuffer();
  if (signed) {
    buffer.write(negative ? '-' : '+');
  } else if (negative) {
    buffer.write('-');
  }
  buffer.write('R');
  buffer.write(_groupThousands(rand));
  if (cents || remainder != 0) {
    buffer.write('.');
    buffer.write(remainder.toString().padLeft(2, '0'));
  }
  return buffer.toString();
}

/// Groups digits into threes with a non-breaking space: `1978` -> `1 978`.
String _groupThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
