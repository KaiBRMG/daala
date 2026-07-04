/// Formats ZAR minor units as `R1 250`, `R450`, `R37.50` (DESIGN.md §1.1).
/// The single currency formatter — never hand-format inline.
String formatZar(int zarMinor) {
  final sign = zarMinor < 0 ? '-' : '';
  final abs = zarMinor.abs();
  final rand = abs ~/ 100;
  final cents = abs % 100;

  final digits = rand.toString();
  final grouped = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(' ');
    grouped.write(digits[i]);
  }

  final centsPart =
      cents == 0 ? '' : '.${cents.toString().padLeft(2, '0')}';
  return '${sign}R$grouped$centsPart';
}
