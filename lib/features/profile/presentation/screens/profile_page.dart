import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/core/widgets/user_avatar.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';

/// Onglet Profil — spec `FLUTTER_PROTOTYPE_SPEC.md` §8 « ProfileScreen ».
///
/// UserCard (avatar/identité) + 3 stats dérivées + menu (Mes événements,
/// Paramètres, Support…) + bouton de déconnexion. Statistiques calculées
/// depuis les providers (contrairement aux valeurs codées en dur de la spec,
/// incohérentes avec le reste de l'app).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user.id;
    final eventsCount = ref.watch(myEventsProvider(userId)).value?.length ?? 0;
    final tickets = ref.watch(myTicketsProvider(userId)).value ?? const [];
    final validatedCount = tickets
        .where((ticket) => ticket.status == TicketStatus.used)
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.pageTop,
            AppSpacing.pageHorizontal,
            AppSpacing.bottomClearanceWithNav,
          ),
          children: [
            PageHeader(
              title: 'Profil',
              showBack: true,
              onBack: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: AppSpacing.lg),
            _UserCard(user: user),
            const SizedBox(height: AppSpacing.lg),
            _StatsRow(
              eventsCount: eventsCount,
              ticketsCount: tickets.length,
              validatedCount: validatedCount,
            ),
            const SizedBox(height: AppSpacing.lg),
            _Menu(
              onMyEvents: () => context.go(AppRoutes.tickets),
              onStub: (label) => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('$label — bientôt disponible')),
                ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Se déconnecter',
              variant: AppButtonVariant.secondary,
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Déconnexion — auth à venir (sprint infras)'),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      mode: GlassCardMode.elevated,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.avatarBackground,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: UserAvatar(size: 80, name: user.fullName),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            user.fullName,
            style: const TextStyle(
              fontFamily: AppTypography.display,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3 cartes stats — spec §8 (icône + valeur + libellé), dérivées du domaine.
class _StatsRow extends StatelessWidget {
  final int eventsCount;
  final int ticketsCount;
  final int validatedCount;

  const _StatsRow({
    required this.eventsCount,
    required this.ticketsCount,
    required this.validatedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_month,
            value: '$eventsCount',
            label: 'Événements',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.confirmation_number_outlined,
            value: '$ticketsCount',
            label: 'Billets',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            value: '$validatedCount',
            label: 'Validés',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 25, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: AppTypography.ui,
                  fontSize: 26,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

/// Menu — spec §8 (Mes événements créés, Paramètres, Support, À propos).
class _Menu extends StatelessWidget {
  final VoidCallback onMyEvents;
  final ValueChanged<String> onStub;

  const _Menu({required this.onMyEvents, required this.onStub});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.calendar_month_outlined,
            label: 'Mes événements créés',
            onTap: onMyEvents,
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Paramètres',
            onTap: () => onStub('Paramètres'),
          ),
          _MenuItem(
            icon: Icons.help_outline,
            label: 'Support',
            onTap: () => onStub('Support'),
          ),
          _MenuItem(
            icon: Icons.info_outline,
            label: 'À propos',
            onTap: () => onStub('À propos'),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PressableScale(
          onTap: onTap,
          pressedScale: 0.97,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: AppSpacing.xxxl),
      ],
    );
  }
}