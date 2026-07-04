import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Star display / selector. Interactive when [onChanged] is provided
/// (Leave Review's large 5-star selector).
// TODO(spec): star colour unspecified — uses status.pending (amber) so
// orange stays reserved for attention signals.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = DaalaSizes.iconSm,
    this.onChanged,
  });

  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: Padding(
              padding: EdgeInsets.only(
                  right: onChanged == null ? 0 : DaalaSpacing.s8),
              child: Icon(
                i <= rating ? Icons.star : Icons.star_border,
                size: size,
                color: i <= rating
                    ? DaalaColors.statusPending
                    : DaalaColors.ink300,
              ),
            ),
          ),
      ],
    );
  }
}
