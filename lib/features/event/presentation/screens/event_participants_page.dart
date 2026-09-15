import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/widgets/app_top_bar.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

import '../providers/event_providers.dart';

/// Participants d'un événement — détenteurs de billets attribués.
///
/// Route plein-écran (cache la barre de navigation), réservée aux
/// organisateurs et contrôleurs. L'organisateur peut désigner un contrôleur
/// (UC24) sur place.
class EventParticipantsPage extends ConsumerWidget {
  final String eventId;

  const EventParticipantsPage({super.key, required this.eventId});

  Future<void> _designate(
    BuildContext context,
    WidgetRef ref,
    String participantId,
  ) async {
    try {
      await ref
          .read(assignRoleProvider)
          .call(
            EventUserRole(
              userId: participantId,
              eventId: eventId,
              role: Role.controller,
            ),
          );
      ref.invalidate(eventRolesProvider(eventId));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$participantId est désormais contrôleur.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)!.id;
    final rolesAsync = ref.watch(eventRolesProvider(eventId));
    final participantsAsync = ref.watch(eventParticipantsProvider(eventId));
    final eventAsync = ref.watch(eventProvider(eventId));

    final roles = rolesAsync.value ?? const <EventUserRole>[];
    final canManage = roles.any(
      (role) =>
          role.userId == userId &&
          (role.role == Role.organiser || role.role == Role.controller),
    );
    final isOrganizer = roles.any(
      (role) => role.userId == userId && role.role == Role.organiser,
    );

    if (!canManage) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            AppTopBar(
              title: 'Participants',
              subtitle: eventAsync.value?.title,
              showBack: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  0,
                  AppSpacing.pageHorizontal,
                  AppSpacing.bottomClearanceNoNav,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlassCard(
                      mode: GlassCardMode.defaultMode,
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: AppColors.errorText,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Accès réservé aux organisateurs et contrôleurs.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.errorText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          AppTopBar(
            title: 'Participants',
            subtitle: eventAsync.value?.title,
            showBack: true,
          ),
          Expanded(
            child: participantsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text('Erreur : $error')),
              data: (participantIds) {
                final controllerIds = roles
                    .where((role) => role.role == Role.controller)
                    .map((role) => role.userId);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    0,
                    AppSpacing.pageHorizontal,
                    AppSpacing.bottomClearanceNoNav,
                  ),
                  children: [
                    Text(
                      '${participantIds.length} '
                      '${participantIds.length > 1 ? 'participants' : 'participant'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (participantIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: Text(
                            'Aucun participant pour l’instant.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      for (final participantId in participantIds) ...[
                        _ParticipantRow(
                          participantId: participantId,
                          isController: controllerIds.contains(participantId),
                          canDesignate: isOrganizer,
                          onDesignate: () =>
                              _designate(context, ref, participantId),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  final String participantId;
  final bool isController;
  final bool canDesignate;
  final VoidCallback onDesignate;

  const _ParticipantRow({
    required this.participantId,
    required this.isController,
    required this.canDesignate,
    required this.onDesignate,
  });

  @override
  Widget build(BuildContext context) {
    final initial = participantId.isNotEmpty
        ? participantId[0].toUpperCase()
        : '?';

    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantId,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isController) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  const Text(
                    'Contrôleur',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isController)
            const Icon(
              Icons.verified_outlined,
              size: 20,
              color: AppColors.primary,
            )
          else if (canDesignate)
            PressableScale(
              onTap: onDesignate,
              pressedScale: 0.92,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Text(
                  'Désigner contrôleur',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
