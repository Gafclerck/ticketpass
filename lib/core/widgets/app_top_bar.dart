import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'page_header.dart';

/// Barre supérieure fixe — alternative DS à l'`AppBar` Material.
///
/// Peint un fond plein `#080808` derrière la barre de statut (heure /
/// batterie / réseau) puis le [PageHeader] (retour + titre + action). Le
/// contenu scrolle dans un `Expanded` SÉPARÉ, jamais sous les icônes système.
class AppTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageTop,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          child: PageHeader(
            title: title,
            subtitle: subtitle,
            showBack: showBack,
            onBack: onBack,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}

/// Bande supérieure opaque — peint la zone SafeArea du haut en `#080808`.
///
/// Utilisée par les onglets (headers éditoriaux scrollables) : le contenu
/// scrolle toujours sous la bande, donc les icônes système restent sur un
/// fond plein, jamais sur du contenu (image / texte / halo).
class AppSafeTopBand extends StatelessWidget {
  const AppSafeTopBand({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}
