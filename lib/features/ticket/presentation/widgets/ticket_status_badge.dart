import 'package:flutter/material.dart';
import 'package:ticketpass/core/widgets/status_badge.dart';
import '../../domain/entities/ticket_status.dart';

/// Badge de statut de billet — mappe [TicketStatus] vers la variante DS.
class TicketStatusBadge extends StatelessWidget {
  final TicketStatus status;

  const TicketStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: status.label,
      variant: switch (status) {
        TicketStatus.valid => StatusBadgeVariant.green,
        TicketStatus.used => StatusBadgeVariant.gray,
        TicketStatus.unused => StatusBadgeVariant.blue,
        TicketStatus.invalid => StatusBadgeVariant.red,
        TicketStatus.revoked => StatusBadgeVariant.red,
      },
    );
  }
}