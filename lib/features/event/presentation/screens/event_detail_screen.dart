import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

import '../providers/event_providers.dart';

/// Détail d'un événement — route racine (cache la barre de navigation).
///
/// Le contenu s'adapte au rôle de l'utilisateur courant sur l'événement :
/// - organisateur : actions de gestion (modifier, voir les billets) ;
/// - contrôleur : pas d'achat (gestion en Phase 3) ;
/// - visiteur : achat automatique d'un billet (UC19) ;
/// - porteur d'un billet : accès à son billet.
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Ticket? _acquiredTicket;
  bool _isBuying = false;

  Future<void> _acquire(String userId) async {
    setState(() => _isBuying = true);

    try {
      final acquired = await ref
          .read(acquireTicketProvider)
          .call(widget.eventId, userId: userId);

      if (!mounted) return;

      setState(() => _acquiredTicket = acquired);
      ref.invalidate(myTicketsProvider(userId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Billet obtenu ! Retrouvez-le dans votre portefeuille.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error')),
      );
    } finally {
      if (mounted) setState(() => _isBuying = false);
    }
  }

  Future<void> _openEdit(String userId) async {
    final changed = await context.push<bool>(
      '${AppRoutes.eventEdit}?id=${widget.eventId}',
    );

    if (changed == true) {
      ref.invalidate(eventProvider(widget.eventId));
      ref.invalidate(myEventsProvider(userId));
      ref.invalidate(discoverEventsProvider);
    }
  }

  Future<void> _openTickets() async {
    await context.push('${AppRoutes.eventTickets}${widget.eventId}');
    ref.invalidate(eventTicketsProvider(widget.eventId));
  }

  Future<void> _openParticipants() async {
    await context.push(
      '${AppRoutes.eventParticipants}${widget.eventId}',
    );
    ref.invalidate(eventRolesProvider(widget.eventId));
  }

  Future<void> _openScanner() async {
    await context.push('${AppRoutes.scan}${widget.eventId}');
    ref.invalidate(eventTicketsProvider(widget.eventId));
  }

  Future<void> _generateTickets() async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Générer des billets'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantité'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(controller.text);
                Navigator.pop(dialogContext, parsed);
              },
              child: const Text('Générer'),
            ),
          ],
        );
      },
    );

    if (quantity == null) return;

    try {
      await ref
          .read(generateTicketsProvider)
          .call(widget.eventId, quantity);

      if (!mounted) return;

      ref.invalidate(eventTicketsProvider(widget.eventId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$quantity billets générés.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération : $error')),
      );
    }
  }

  Ticket? _findOwnedTicket(List<Ticket> tickets) {
    for (final ticket in tickets) {
      if (ticket.eventId == widget.eventId) return ticket;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));
    final userId = ref.watch(currentUserProvider).id;
    final rolesAsync = ref.watch(eventRolesProvider(widget.eventId));
    final myTicketsAsync = ref.watch(myTicketsProvider(userId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: eventAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(onBack: () => context.pop()),
        data: (event) {
          final roles = rolesAsync.value ?? const <EventUserRole>[];
          final isOrganizer = roles.any(
            (role) => role.userId == userId && role.role == Role.organiser,
          );
          final isController = roles.any(
            (role) => role.userId == userId && role.role == Role.controller,
          );
          final owned =
              _acquiredTicket ??
              _findOwnedTicket(myTicketsAsync.value ?? const []);

          return SafeArea(
            bottom: false,
            child: ListView(
              padding: AppTheme.pagePadding(
                bottom: AppSpacing.bottomClearanceNoNav,
              ),
              children: [
                PageHeader(
                  title: 'Détails',
                  subtitle: event.title,
                  showBack: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                _Hero(event: event),
                const SizedBox(height: AppSpacing.lg),
                _DescriptionCard(description: event.description),
                const SizedBox(height: AppSpacing.sm),
                _InfoCard(event: event),
                const SizedBox(height: AppSpacing.lg),
                if (!rolesAsync.hasValue)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (isOrganizer)
                  _OrganizerActions(
                    onEdit: () => _openEdit(userId),
                    onTickets: _openTickets,
                    onParticipants: _openParticipants,
                    onGenerate: _generateTickets,
                    onScan: _openScanner,
                  )
                else if (owned != null)
                  _OwnedTicketActions(
                    ticketId: owned.id,
                    ticketCode: owned.uniqueCode,
                  )
                else if (isController)
                  _ControllerNotice(onScan: _openScanner)
                else
                  AppButton(
                    label: 'Prendre un billet',
                    fullWidth: true,
                    icon: Icons.confirmation_number,
                    onPressed: _isBuying ? null : () => _acquire(userId),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Bandeau visuel de l'événement — cf. EventCard (image / dégradé + titre).
class _Hero extends StatelessWidget {
  final Event event;

  const _Hero({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(event.eventDate);

    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: event.brandingUrl.isEmpty
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF122033), Color(0xFF080808)],
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: const Color(0x26148CFA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (event.brandingUrl.isNotEmpty)
            Image.network(
              event.brandingUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x8C000000)],
                stops: [0.38, 0.85],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: AppTypography.display,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$dateLabel · ${event.eventPlace}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFA7ABB3),
                      fontSize: 13,
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
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        description,
        style: const TextStyle(
          height: 1.5,
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Event event;

  const _InfoCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(event.eventDate);
    final timeLabel = TimeOfDay.fromDateTime(event.startTime).format(context);

    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.all(AppSpacing.sm * 1.5),
      child: Column(
        children: [
          _InfoRow(icon: Icons.calendar_today, label: 'Date', value: dateLabel),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(icon: Icons.schedule, label: 'Heure', value: timeLabel),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(icon: Icons.place_outlined, label: 'Lieu', value: event.eventPlace),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.category_outlined,
            label: 'Catégorie',
            value: event.type.label,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoRow(
            icon: Icons.confirmation_number,
            label: 'Capacité',
            value: '${event.maxPlaces} places',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Actions de gestion pour l'organisateur.
class _OrganizerActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onTickets;
  final VoidCallback onParticipants;
  final VoidCallback onGenerate;
  final VoidCallback onScan;

  const _OrganizerActions({
    required this.onEdit,
    required this.onTickets,
    required this.onParticipants,
    required this.onGenerate,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Modifier l’événement',
          fullWidth: true,
          icon: Icons.edit_outlined,
          onPressed: onEdit,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Voir les billets',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: Icons.confirmation_number_outlined,
          onPressed: onTickets,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Voir les participants',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: Icons.group_outlined,
          onPressed: onParticipants,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Générer des billets',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: Icons.add_circle_outline,
          onPressed: onGenerate,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Scanner',
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          icon: Icons.qr_code_scanner,
          onPressed: onScan,
        ),
      ],
    );
  }
}

/// Accès au billet déjà possédé par l'utilisateur courant.
class _OwnedTicketActions extends StatelessWidget {
  final String ticketId;
  final String ticketCode;

  const _OwnedTicketActions({
    required this.ticketId,
    required this.ticketCode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Voir mon billet',
          fullWidth: true,
          icon: Icons.qr_code_2,
          onPressed: () =>
              context.push('${AppRoutes.ticketDetail}$ticketId'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ticketCode,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ControllerNotice extends StatelessWidget {
  final VoidCallback onScan;

  const _ControllerNotice({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GlassCard(
          mode: GlassCardMode.defaultMode,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Vous êtes contrôleur de cet événement.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Scanner',
          fullWidth: true,
          icon: Icons.qr_code_scanner,
          onPressed: onScan,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onBack;

  const _ErrorState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Événement introuvable.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Retour',
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}