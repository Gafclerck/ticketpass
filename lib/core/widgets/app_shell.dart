import 'package:flutter/material.dart';
import 'package:ticketpass/core/theme/app_colors.dart';

/// Coquille applicative — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.1.
///
/// Pose le fond `#080808` et le halo bleu radial ambient (top-right,
/// opacité 28% → transparent) sous l'écran courant. Toutes les pages
/// non-fullscreen (hors scanner) sont rendues à l'intérieur.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<Color> _glowColors = [
    Color(0x47148CFA), // rgba(20,140,250, 0.28)
    Color(0x1F148CFA), // rgba(20,140,250, 0.12)
    Color(0x00148CFA), // transparent
  ];
  static const List<double> _glowStops = [0.0, 0.24, 0.58];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.44, -0.92),
                radius: 1.2,
                colors: _glowColors,
                stops: _glowStops,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}