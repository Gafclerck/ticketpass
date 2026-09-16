import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Barre supérieure épinglée — header fixe sous la zone safe, contenu scrollable.
///
/// Au repos (offset 0) le header est transparent, tel qu'il serait posé en
/// tête de contenu ; dès que le corps scrolle, il reste collé sous la barre de
/// statut et reçoit un fond plein `#080808` qui masque le contenu passant
/// dessous (comportement commun aux écrans Home / Événements / Mes billets /
/// Profil). La bande safe (`AppSafeTopBand`) reste à la charge de la page.
class PinnedTopBar extends StatefulWidget {
  final Widget header;
  final Widget body;
  final EdgeInsetsGeometry headerPadding;

  const PinnedTopBar({
    super.key,
    required this.header,
    required this.body,
    this.headerPadding = const EdgeInsets.fromLTRB(
      AppSpacing.pageHorizontal,
      AppSpacing.pageTop,
      AppSpacing.pageHorizontal,
      0,
    ),
  });

  @override
  State<PinnedTopBar> createState() => _PinnedTopBarState();
}

class _PinnedTopBarState extends State<PinnedTopBar> {
  bool _scrolled = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    final scrolled = notification.metrics.pixels > 0;
    if (scrolled != _scrolled) {
      setState(() => _scrolled = scrolled);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          color: _scrolled ? AppColors.background : Colors.transparent,
          child: Padding(padding: widget.headerPadding, child: widget.header),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.body,
          ),
        ),
      ],
    );
  }
}
