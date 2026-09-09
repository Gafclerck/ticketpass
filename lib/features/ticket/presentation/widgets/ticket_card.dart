import 'package:flutter/material.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';

import '../../domain/entities/ticket.dart';
import 'ticket_status_badge.dart';

/// Carte billet — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.4 (variante défaut).
///
/// Bouton/zone QR à gauche, titre Playfair + badge de statut + code unique
/// à droite, plein écran (rue de la liste « Mes billets »).
class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: GlassCard(
        mode: GlassCardMode.defaultMode,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0x26148CFA), // primary à 15%
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billet #${ticket.id.split('-').last.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.display,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TicketStatusBadge(status: ticket.status),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ticket.uniqueCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}