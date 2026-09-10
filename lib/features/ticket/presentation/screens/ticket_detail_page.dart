import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';

import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_status_badge.dart';

/// UC8 — Consultation d'un billet (détail + QR de présentation au contrôle).
class TicketDetailPage extends ConsumerWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketProvider(ticketId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (ticket) => SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: AppTheme.pagePadding(
              bottom: AppSpacing.bottomClearanceNoNav,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(title: 'Mon billet', showBack: true),
                const SizedBox(height: AppSpacing.lg),
                _BilletCard(ticket: ticket),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BilletCard extends StatelessWidget {
  final Ticket ticket;

  const _BilletCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      mode: GlassCardMode.elevated,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TicketStatusBadge(status: ticket.status),
          ),
          const SizedBox(height: AppSpacing.md),
          // fond blanc pour rendre le QR lisible sur thème sombre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.box),
            ),
            child: QrImageView(
              data: ticket.qrSignature,
              version: QrVersions.auto,
              size: 220,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Billet #${ticket.id.split('-').last.toUpperCase()}',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            ticket.uniqueCode,
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}