import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/app_top_bar.dart';
import 'package:ticketpass/core/widgets/empty_state.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pinned_top_bar.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_card.dart';

/// UC9 — Historique des billets possédés par l'utilisateur courant.
///
/// L'import de billet (UC7) est supprimé : un billet s'obtient uniquement
/// en « Obtenant un billet » depuis le détail d'un événement (UC19).
class MyTicketsPage extends ConsumerWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider).id;
    final ticketsAsync = ref.watch(myTicketsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // bande opaque : le contenu scrolle sous, jamais sur les icônes
          const AppSafeTopBand(),
          Expanded(
            child: ticketsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Erreur : $error')),
              data: (tickets) {
                return PinnedTopBar(
                  header: const PageHeader(title: 'Mes billets'),
                  body: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      0,
                      AppSpacing.pageHorizontal,
                      AppSpacing.bottomClearanceWithNav,
                    ),
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      if (tickets.isEmpty)
                        EmptyState(
                          icon: Icons.qr_code_scanner,
                          title: 'Aucun billet',
                          subtitle:
                              'Obtenez votre billet depuis la page d’un '
                              'événement.',
                          action: AppButton(
                            label: 'Découvrir des événements',
                            fullWidth: true,
                            icon: Icons.explore_outlined,
                            onPressed: () => context.go(AppRoutes.home),
                          ),
                        )
                      else
                        ...tickets.map(
                          (ticket) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: TicketCard(
                              ticket: ticket,
                              onTap: () => context.push(
                                '${AppRoutes.ticketDetail}${ticket.id}',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
