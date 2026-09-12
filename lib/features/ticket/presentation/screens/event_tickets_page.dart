import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/app_search_field.dart';
import 'package:ticketpass/core/widgets/page_header.dart';

import '../../../event/presentation/providers/event_providers.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_status_badge.dart';

enum _TicketFilter { all, valid, used }

/// UC6 — Liste des billets générés pour un événement (vue organisateur).
/// À ne pas confondre avec `my_tickets_page.dart` (UC9, vue porteur).
class EventTicketsPage extends ConsumerWidget {
  final String eventId;

  const EventTicketsPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final ticketsAsync = ref.watch(eventTicketsProvider(eventId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (tickets) => _EventTicketsBody(
          eventTitle: eventAsync.value?.title,
          tickets: tickets,
        ),
      ),
    );
  }
}

class _EventTicketsBody extends StatefulWidget {
  final String? eventTitle;
  final List<Ticket> tickets;

  const _EventTicketsBody({required this.eventTitle, required this.tickets});

  @override
  State<_EventTicketsBody> createState() => _EventTicketsBodyState();
}

class _EventTicketsBodyState extends State<_EventTicketsBody> {
  final _searchController = TextEditingController();
  _TicketFilter _filter = _TicketFilter.all;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ticket> get _filteredTickets {
    return widget.tickets.where((ticket) {
      final matchesFilter = switch (_filter) {
        _TicketFilter.all => true,
        _TicketFilter.valid => ticket.status == TicketStatus.valid,
        _TicketFilter.used => ticket.status == TicketStatus.used,
      };
      final matchesQuery =
          _query.isEmpty ||
          ticket.uniqueCode.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.tickets.length;
    final validCount = widget.tickets
        .where((t) => t.status == TicketStatus.valid)
        .length;
    final usedCount = widget.tickets
        .where((t) => t.status == TicketStatus.used)
        .length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: AppTheme.pagePadding(bottom: AppSpacing.bottomClearanceNoNav),
        children: [
          PageHeader(title: 'Billets', subtitle: widget.eventTitle, showBack: true),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: total,
                  label: 'Total',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  value: validCount,
                  label: 'Valides',
                  color: AppColors.successText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  value: usedCount,
                  label: 'Utilisés',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSearchField(
            controller: _searchController,
            hintText: 'Rechercher un billet...',
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _FilterChip(
                label: 'Tous',
                selected: _filter == _TicketFilter.all,
                onTap: () => setState(() => _filter = _TicketFilter.all),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterChip(
                label: 'Valides',
                selected: _filter == _TicketFilter.valid,
                onTap: () => setState(() => _filter = _TicketFilter.valid),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterChip(
                label: 'Utilisés',
                selected: _filter == _TicketFilter.used,
                onTap: () => setState(() => _filter = _TicketFilter.used),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_filteredTickets.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Text(
                  'Aucun billet ne correspond.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            for (final ticket in _filteredTickets) ...[
              _TicketRow(ticket: ticket),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.glassSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: selected ? null : Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _TicketRow extends StatelessWidget {
  final Ticket ticket;

  const _TicketRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.uniqueCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (ticket.userId.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  const Text(
                    'Non attribué',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TicketStatusBadge(status: ticket.status),
        ],
      ),
    );
  }
}
