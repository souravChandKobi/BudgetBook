import 'package:flutter/material.dart';

class ItemCardSkeleton extends StatelessWidget {
  const ItemCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

