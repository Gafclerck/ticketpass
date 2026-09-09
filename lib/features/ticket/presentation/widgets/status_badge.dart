import 'package:flutter/material.dart';

import '../../domain/entities/ticket_status.dart';

/// Badge coloré du statut d'un billet — UC8/UC9.
class TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;

  const TicketStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      TicketStatus.valid => (Colors.green.shade700, Colors.white),
      TicketStatus.used => (Colors.blueGrey.shade600, Colors.white),
      TicketStatus.unused => (Colors.amber.shade700, Colors.black87),
      TicketStatus.invalid => (Colors.red.shade700, Colors.white),
      TicketStatus.revoked => (Colors.deepPurple.shade700, Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}