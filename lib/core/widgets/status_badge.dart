import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_colors.dart';

/// Badge de statut — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.9.
///
/// Fond teinté `rgba(couleur, 0.20)`, texte couleur (variante), bordure
/// `rgba(couleur, 0.30)`, pill, 12px medium. 4 variantes : blue/green/red/gray.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;

  const StatusBadge({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      StatusBadgeVariant.blue => (
          const Color(0x33148CFA),
          AppColors.primary,
          AppColors.primaryBorder,
        ),
      StatusBadgeVariant.green => (
          const Color(0x3322C55E),
          AppColors.successText,
          const Color(0x4D22C55E),
        ),
      StatusBadgeVariant.red => (
          const Color(0x33EF4444),
          AppColors.errorText,
          const Color(0x4DEF4444),
        ),
      StatusBadgeVariant.gray => (
          const Color(0x1AFFFFFF),
          AppColors.textSecondary,
          AppColors.glassBorder,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

enum StatusBadgeVariant { blue, green, red, gray }