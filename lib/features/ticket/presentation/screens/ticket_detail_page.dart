import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/status_badge.dart';

/// UC8 — Consultation d'un billet (détail + QR de présentation au contrôle).
class TicketDetailPage extends ConsumerWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketProvider(ticketId));

    return Scaffold(
      appBar: AppBar(title: const Text('Mon billet')),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (ticket) => _BilletCard(ticket: ticket),
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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TicketStatusBadge(status: ticket.status),
                const SizedBox(height: 16),
                QrImageView(
                  data: ticket.qrSignature,
                  version: QrVersions.auto,
                  size: 220,
                ),
                const SizedBox(height: 16),
                Text('Billet #${ticket.id.split('-').last.toUpperCase()}',
                    style: textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(
                  ticket.uniqueCode,
                  style: textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}