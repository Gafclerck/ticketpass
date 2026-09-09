import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/providers/current_user_provider.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/status_badge.dart';

/// UC9 — Historique des billets possédés par l'utilisateur courant.
class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final userId = ref.read(currentUserIdProvider);
    final importTicket = ref.read(importTicketProvider);

    final imported = await showDialog<Ticket>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Importer un billet'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Code du billet',
              helperText: 'Saisissez le code unique indiqué sur votre billet.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isEmpty) return;

                try {
                  final ticket = await importTicket(code, userId: userId);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, ticket);
                  }
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Import impossible : $error')),
                    );
                  }
                }
              },
              child: const Text('Importer'),
            ),
          ],
        );
      },
    );

    if (imported == null || !context.mounted) return;

    ref.invalidate(myTicketsProvider(userId));

    context.push('${AppRoutes.ticketDetail}${imported.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final ticketsAsync = ref.watch(myTicketsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Mes billets'), centerTitle: true),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(
              child: Text('Aucun billet importé pour le moment.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return _TicketCard(ticket: ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showImportDialog(context, ref),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Importer un billet'),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('${AppRoutes.ticketDetail}${ticket.id}'),
        leading: const CircleAvatar(child: Icon(Icons.confirmation_number)),
        title: Text('Billet #${ticket.id.split('-').last.toUpperCase()}'),
        subtitle: Text(ticket.uniqueCode),
        trailing: TicketStatusBadge(status: ticket.status),
      ),
    );
  }
}