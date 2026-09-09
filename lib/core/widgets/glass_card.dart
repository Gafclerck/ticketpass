import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_colors.dart';

/// Carte en verre — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.14.
///
/// Default : white/10 + blur 24 + bordure white/12.
/// Elevated : white/14 + blur 28 + bordure white/16.
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassCardMode mode;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.mode = GlassCardMode.defaultMode,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final (background, blur, border) = switch (mode) {
      GlassCardMode.defaultMode => (
          AppColors.glassSurface,
          24.0,
          AppColors.glassBorder,
        ),
      GlassCardMode.elevated => (
          AppColors.glassElevated,
          28.0,
          AppColors.borderElevated,
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}

enum GlassCardMode { defaultMode, elevated }