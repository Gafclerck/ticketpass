import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_colors.dart';
import 'pressable_scale.dart';

/// Bouton DS — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.12.
///
/// Variantes : primary (fil `#148cfa`), secondary (verre white/10),
/// ghost (transparent, texte accent).
/// Tailles : sm (40), md (48), lg (56, défaut).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final bool enabled;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.fullWidth = false,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    final foreground = switch (variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.secondary => AppColors.textPrimary,
      AppButtonVariant.ghost => AppColors.primary,
      AppButtonVariant.danger => Colors.white,
    };

    final background = switch (variant) {
      AppButtonVariant.primary => AppColors.primary,
      AppButtonVariant.secondary => AppColors.glassSurface,
      AppButtonVariant.ghost => Colors.transparent,
      AppButtonVariant.danger => AppColors.error,
    };

    final border = switch (variant) {
      AppButtonVariant.secondary => Border.all(
          color: AppColors.borderStandard,
        ),
      AppButtonVariant.ghost => Border.all(color: Colors.transparent),
      AppButtonVariant.primary || AppButtonVariant.danger => null,
    };

    final height = switch (size) {
      AppButtonSize.sm => 40.0,
      AppButtonSize.md => 48.0,
      AppButtonSize.lg => 56.0,
    };
    final horizontalPadding = switch (size) {
      AppButtonSize.sm => 20.0,
      AppButtonSize.md => 24.0,
      AppButtonSize.lg => 24.0,
    };
    final fontSize = switch (size) {
      AppButtonSize.sm => 14.0,
      AppButtonSize.md => 16.0,
      AppButtonSize.lg => 16.0,
    };

    return PressableScale(
      onTap: isEnabled ? onPressed : null,
      pressedScale: 0.95,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.45,
        child: Container(
          height: height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: isEnabled ? background : AppColors.glassSurface,
            border: isEnabled ? border : null,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: variant == AppButtonVariant.primary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 4, color: foreground),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { sm, md, lg }