import 'package:flutter/material.dart';

/// 1-5 stars. Read-only when [onChanged] is null. Tapping the current
/// rating's star clears it (rating is optional everywhere in the app).
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, this.rating, this.onChanged, this.size = 24});

  final int? rating;
  final ValueChanged<int?>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          GestureDetector(
            onTap: onChanged == null
                ? null
                : () => onChanged!(star == rating ? null : star),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                (rating ?? 0) >= star ? Icons.star : Icons.star_border,
                size: size,
                color: color,
                semanticLabel: onChanged != null && star == 1
                    ? 'Rating: ${rating ?? 0} of 5'
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
