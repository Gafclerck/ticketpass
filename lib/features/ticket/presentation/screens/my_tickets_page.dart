import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/empty_state.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import '../../domain/entities/ticket.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_card.dart';

/// UC9 — Historique des billets possédés par l'utilisateur courant.
///
/// Header DS + carte d'import en tête + TicketCards. Le CTA d'import est
/// DANS le contenu (jamais de FAB : il serait caché par la nav flottante).
class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});

  Future<void> _showImportDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final userId = ref.read(currentUserProvider).id;
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
    final userId = ref.watch(currentUserProvider).id;
    final ticketsAsync = ref.watch(myTicketsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ticketsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
          data: (tickets) {
            return ListView(
              padding: AppTheme.pagePadding(
                bottom: AppSpacing.bottomClearanceWithNav,
              ),
              children: [
                const PageHeader(title: 'Mes billets'),
                const SizedBox(height: AppSpacing.lg),
                if (tickets.isEmpty)
                  EmptyState(
                    icon: Icons.qr_code_scanner,
                    title: 'Aucun billet',
                    subtitle: 'Importez votre premier billet grâce au code '
                        'unique indiqué dessus.',
                    action: AppButton(
                      label: 'Importer un billet',
                      fullWidth: true,
                      icon: Icons.qr_code_scanner,
                      onPressed: () => _showImportDialog(context, ref),
                    ),
                  )
                else ...[
                  _ImportTile(
                    onTap: () => _showImportDialog(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...tickets.map(
                    (ticket) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TicketCard(
                        ticket: ticket,
                        onTap: () => context.push(
                          '${AppRoutes.ticketDetail}${ticket.id}',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Élément d'import en tête de liste — spec §8 « Importer un billet ».
class _ImportTile extends StatelessWidget {
  final VoidCallback onTap;

  const _ImportTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: GlassCard(
        mode: GlassCardMode.defaultMode,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: const Row(
          children: [
            Icon(Icons.qr_code_scanner, size: 22, color: AppColors.primary),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Importer un billet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}