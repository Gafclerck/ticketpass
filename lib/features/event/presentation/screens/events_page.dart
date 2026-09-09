import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/empty_state.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import '../../domain/entities/event.dart';
import '../providers/event_providers.dart';
import '../widgets/event_card.dart';

/// Mes événements (organisateur) — liste des créations de l'utilisateur.
///
/// Header DS + CTA « Créer un événement » en tête + EventCards.
/// Le CTA est DANS le contenu (jamais de FAB : il serait caché par la nav).
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final isCreated = await context.push<bool>(AppRoutes.eventCreate);

    if (isCreated == true) {
      ref.invalidate(myEventsProvider(ref.read(currentUserProvider).id));
      ref.invalidate(discoverEventsProvider);
    }
  }

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    Event event,
  ) async {
    final isUpdated = await context.push<bool>(
      '${AppRoutes.eventEdit}?id=${event.id}',
    );

    if (isUpdated == true) {
      ref.invalidate(myEventsProvider(ref.read(currentUserProvider).id));
      ref.invalidate(discoverEventsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider).id;
    final eventsAsync = ref.watch(myEventsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
          data: (events) {
            return ListView(
              padding: AppTheme.pagePadding(
                bottom: AppSpacing.bottomClearanceWithNav,
              ),
              children: [
                PageHeader(
                  title: 'Mes événements',
                  subtitle: '${events.length} '
                      '${events.length > 1 ? 'événements' : 'événement'}',
                ),
                const SizedBox(height: AppSpacing.lg),
                if (events.isEmpty)
                  EmptyState(
                    icon: Icons.add_circle_outline,
                    title: 'Aucun événement',
                    subtitle: 'Organisez votre premier événement et vendez '
                        'vos billets en quelques étapes.',
                    action: AppButton(
                      label: 'Créer un événement',
                      fullWidth: true,
                      icon: Icons.add,
                      onPressed: () => _openCreate(context, ref),
                    ),
                  )
                else ...[
                  _CreateTile(onTap: () => _openCreate(context, ref)),
                  const SizedBox(height: AppSpacing.md),
                  ...events.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: EventCard(
                        event: event,
                        onTap: () => _openEdit(context, ref, event),
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

/// CTA de création en tête de liste.
class _CreateTile extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateTile({required this.onTap});

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
            Icon(Icons.add_circle, size: 22, color: AppColors.primary),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Créer un événement',
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