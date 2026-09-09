import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'pressable_scale.dart';

/// Bouton retour standard — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.7.
///
/// Cercle 44×44 en verre white/10, bordure white/12, chevron blanc 20.
class BackButtonCircle extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonCircle({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.9,
      onTap: onPressed ?? () => context.pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}