import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/app_top_bar.dart';
import 'package:ticketpass/core/widgets/back_button_circle.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/core/widgets/user_avatar.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_user_role.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

import '../providers/event_providers.dart';

/// Détail d'un événement — route racine (cache la barre de navigation).
///
/// Conforme à la spec `FLUTTER_PROTOTYPE_SPEC.md` §8 : `FloatingHeader` sur le
/// hero, hero 320px (radius 32), `MetadataGrid` (Date/Horaire), section
/// « À propos », jauge de capacité (organisateur), et CTA selon le rôle :
/// - visiteur → barre basse « Obtenir un billet » (UC19 puis `/ticket/:id`) ;
/// - porteur  → barre basse « Voir mon billet » ;
/// - organisateur → pile flottante droite (Générer primaire, puis Voir les
///   billets / Participants / Modifier / Scanner) ;
/// - contrôleur → pile flottante droite (Scanner).
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Ticket? _acquiredTicket;
  bool _isBuying = false;
  bool _headerScrolled = false;

  bool _handleScrollNotification(ScrollNotification notification) {
    final scrolled = notification.metrics.pixels > 0;
    if (scrolled != _headerScrolled) {
      setState(() => _headerScrolled = scrolled);
    }
    return false;
  }

  Future<void> _acquire(String userId) async {
    setState(() => _isBuying = true);

    try {
      final acquired = await ref
          .read(acquireTicketProvider)
          .call(widget.eventId, userId: userId);

      if (!mounted) return;

      setState(() => _acquiredTicket = acquired);
      ref.invalidate(myTicketsProvider(userId));

      // ROADMAP : redistribution automatique puis redirection vers le billet.
      context.push('${AppRoutes.ticketDetail}${acquired.id}');
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
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
    await context.push('${AppRoutes.eventParticipants}${widget.eventId}');
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
            decoration: const InputDecoration(labelText: 'Nombre de billets'),
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
      await ref.read(generateTicketsProvider).call(widget.eventId, quantity);

      if (!mounted) return;

      ref.invalidate(eventTicketsProvider(widget.eventId));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$quantity billets générés.')));
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
    final participantsAsync = ref.watch(
      eventParticipantsProvider(widget.eventId),
    );

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
          final sold = participantsAsync.value?.length ?? 0;

          final hasBottomCta = !isOrganizer && !isController;
          final bottomClearance = hasBottomCta
              ? AppSpacing.bottomClearanceWithNav
              : AppSpacing.bottomClearanceNoNav;

          return Stack(
            children: [
              SafeArea(
                bottom: false,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: ListView(
                    padding: EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: bottomClearance,
                    ),
                    children: [
                      // Hero (spec : mx 16, mt 16, height 320, radius 32)
                      _Hero(event: event, participantCount: sold),
                      // Contenu (spec : px 20, pt 20, gap 20)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OrganizerRow(
                              brandName: event.brandName,
                              place: event.eventPlace,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _MetadataGrid(event: event),
                            const SizedBox(height: AppSpacing.lg),
                            _DescriptionSection(description: event.description),
                            const SizedBox(height: AppSpacing.lg),
                            if (isOrganizer) ...[
                              _CapacityBlock(
                                sold: sold,
                                capacity: event.maxPlaces,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            if (isController) ...[
                              const _ControllerNotice(),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            if (!rolesAsync.hasValue)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.lg),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // FloatingHeader absolu au-dessus du hero (spec §8), posé sous
              // une bande opaque : les icônes système restent sur fond plein,
              // le contenu (hero) ne passe jamais derrière elles.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const AppSafeTopBand(),
                    _FloatingHeader(
                      title: event.title,
                      scrolled: _headerScrolled,
                    ),
                  ],
                ),
              ),

              // CTA selon le rôle
              if (hasBottomCta)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomCtaBar(
                    child: owned != null
                        ? AppButton(
                            label: 'Voir mon billet',
                            fullWidth: true,
                            icon: Icons.qr_code_2,
                            onPressed: () => context.push(
                              '${AppRoutes.ticketDetail}${owned.id}',
                            ),
                          )
                        : AppButton(
                            label: 'Obtenir un billet',
                            fullWidth: true,
                            icon: Icons.confirmation_number,
                            onPressed: _isBuying
                                ? null
                                : () => _acquire(userId),
                          ),
                  ),
                )
              else
                Positioned(
                  right: AppSpacing.md,
                  bottom: AppSpacing.bottomClearanceWithNav,
                  child: _FloatingActions(
                    actions: isOrganizer
                        ? [
                            _FloatingAction(
                              label: 'Générer',
                              icon: Icons.confirmation_number,
                              primary: true,
                              onTap: _generateTickets,
                            ),
                            _FloatingAction(
                              label: 'Voir les billets',
                              icon: Icons.list_alt,
                              onTap: _openTickets,
                            ),
                            _FloatingAction(
                              label: 'Participants',
                              icon: Icons.people_alt_outlined,
                              onTap: _openParticipants,
                            ),
                            _FloatingAction(
                              label: 'Modifier',
                              icon: Icons.edit_outlined,
                              onTap: () => _openEdit(userId),
                            ),
                            _FloatingAction(
                              label: 'Scanner',
                              icon: Icons.qr_code_scanner,
                              onTap: _openScanner,
                            ),
                          ]
                        : [
                            _FloatingAction(
                              label: 'Scanner',
                              icon: Icons.qr_code_scanner,
                              primary: true,
                              onTap: _openScanner,
                            ),
                          ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FloatingHeader
// ---------------------------------------------------------------------------

/// Header flottant (spéc §8) : bouton retour + titre + bouton partage.
///
/// Transparent au repos (posé sur le hero) ; dès que le contenu scrolle,
/// reçoit un fond plein `#080808` qui masque ce qui passe dessous.
class _FloatingHeader extends StatelessWidget {
  final String title;
  final bool scrolled;

  const _FloatingHeader({required this.title, required this.scrolled});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      color: scrolled ? AppColors.background : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const BackButtonCircle(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const _ShareButton(),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      pressedScale: 0.9,
      onTap: () {},
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: const Icon(Icons.ios_share, color: Colors.white, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

/// Bandeau visuel — spec §8 : image couverture + dégradé + avatar row + titre.
class _Hero extends StatelessWidget {
  final Event event;
  final int participantCount;

  const _Hero({required this.event, required this.participantCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Container(
        height: 320,
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
            // Dégradé bas (rgba(0,0,0,0.80) → transparent) pour la lisibilité
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
            // Overlay bas (p: 20) : avatar row + titre Playfair
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroAvatarRow(participantCount: participantCount),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontFamily: AppTypography.display,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar row + compteur de participants (spéc : 3 × 28px, offset -8px).
class _HeroAvatarRow extends StatelessWidget {
  final int participantCount;

  const _HeroAvatarRow({required this.participantCount});

  @override
  Widget build(BuildContext context) {
    const avatars = ['A', 'B', 'C'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < avatars.length; i++)
          Transform.translate(
            // chevauchement de 8px entre les cercles (spéc §8)
            offset: Offset(i == 0 ? 0 : -10.0 * i, 0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(width: 2)),
              ),
              child: UserAvatar(name: avatars[i], size: 28),
            ),
          ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          participantCount > 0 ? '+$participantCount participants' : 'En ligne',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Contenu
// ---------------------------------------------------------------------------

/// Ligne organisateur (spec : avatar 48 + nom + lieu · cœur à droite).
class _OrganizerRow extends StatelessWidget {
  final String brandName;
  final String place;

  const _OrganizerRow({required this.brandName, required this.place});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: brandName, size: 48),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                brandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                place,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _HeartButton(),
      ],
    );
  }
}

/// Cœur décoratif 40×40 glass (spéc §8 ; non câblé dans le prototype).
class _HeartButton extends StatefulWidget {
  @override
  State<_HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<_HeartButton> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => setState(() => _liked = !_liked),
      pressedScale: 0.9,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          _liked ? Icons.favorite : Icons.favorite_border,
          size: 20,
          color: _liked ? AppColors.errorText : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Grille métadonnées — spec §8 : chips Date / Horaire (h56, radius 20).
class _MetadataGrid extends StatelessWidget {
  final Event event;

  const _MetadataGrid({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(event.eventDate);
    final timeLabel = TimeOfDay.fromDateTime(event.startTime).format(context);

    return Row(
      children: [
        Expanded(
          child: _MetadataChip(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: dateLabel,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetadataChip(
            icon: Icons.schedule,
            label: 'Horaire',
            value: timeLabel,
          ),
        ),
      ],
    );
  }
}

/// Chip métadonnée — spec §8 : icône 20 primary + label 11 + valeur 15 bold.
class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSubtle,
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Section « À propos » — spec §8 : titre 18 bold + corps 15 gris clair.
class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Bloc capacité (organisateur seul) — spec §8 : jauge 8px pleinement arrondie.
class _CapacityBlock extends StatelessWidget {
  final int sold;
  final int capacity;

  const _CapacityBlock({required this.sold, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final ratio = capacity > 0 ? (sold / capacity).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSubtle,
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Jauge',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                '$sold / $capacity',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rappel d'information pour un contrôleur (le CTA Scanner est flottant).
class _ControllerNotice extends StatelessWidget {
  const _ControllerNotice();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
              'Vous êtes contrôleur de cet événement : utilisez le bouton '
              'Scanner pour valider les billets.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CTA par rôle
// ---------------------------------------------------------------------------

/// Barre basse fixe — spec §8 : verre rgba(8,8,8,0.92) + blur + bordure haute.
class _BottomCtaBar extends StatelessWidget {
  final Widget child;

  const _BottomCtaBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            decoration: const BoxDecoration(
              color: AppColors.overlayStrong,
              border: Border(top: BorderSide(color: Color(0x0FFFFFFF))),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Action flottante — spec §5.6 : primaire 52px / secondaire 44px + pilule.
class _FloatingAction {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _FloatingAction({
    required this.label,
    required this.icon,
    this.primary = false,
    required this.onTap,
  });
}

/// Pile flottante droite — spec §8 : Positioned(right: 16, bottom: 112).
class _FloatingActions extends StatelessWidget {
  final List<_FloatingAction> actions;

  const _FloatingActions({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _FloatingActionItem(action: actions[i]),
        ],
      ],
    );
  }
}

/// Item flottant — la pilule de libellé n'apparaît qu'au survol (hover),
/// jamais fixée (spéc §5.6 : opacity 0 par défaut, révélée au hover 200 ms).
class _FloatingActionItem extends StatefulWidget {
  final _FloatingAction action;

  const _FloatingActionItem({required this.action});

  @override
  State<_FloatingActionItem> createState() => _FloatingActionItemState();
}

class _FloatingActionItemState extends State<_FloatingActionItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final size = action.primary ? 52.0 : 44.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        height: size,
        child: Stack(
          alignment: Alignment.centerRight,
          clipBehavior: Clip.none,
          children: [
            // Pilule à gauche du cercle, masquée par défaut (hover uniquement)
            Positioned(
              right: size + AppSpacing.xs,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: _labelPill(action),
                ),
              ),
            ),
            PressableScale(
              onTap: action.onTap,
              pressedScale: 0.9,
              child: _actionCircle(action),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelPill(_FloatingAction action) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlayDark,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Text(
        action.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: action.primary ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _actionCircle(_FloatingAction action) {
    if (action.primary) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(action.icon, size: 24, color: Colors.white),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.glassStandard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderStandard),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(action.icon, size: 22, color: AppColors.textPrimary),
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
          AppButton(label: 'Retour', onPressed: onBack),
        ],
      ),
    );
  }
}
