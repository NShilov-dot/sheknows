import 'package:flutter/material.dart';
import 'package:sheknows/core/theme/app_spacing.dart';

/// A blank rounded block standing in for content that has not arrived yet.
/// Deliberately static — no shimmer, no animation. Shared by every screen
/// with a loading silhouette.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.swatch,
  });

  /// Null stretches to the available width.
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
