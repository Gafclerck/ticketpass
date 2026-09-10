import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/widgets/app_search_field.dart';
import 'package:ticketpass/core/widgets/empty_state.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/core/widgets/user_avatar.dart';

import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import 'package:ticketpass/features/event/presentation/widgets/event_card.dart';

/// Onglet Découverte — spec `FLUTTER_PROTOTYPE_SPEC.md` §8 « HomeScreen ».
///
/// Bandeau + segment Buy/Sell/Create + recherche + filtres par catégorie
/// + liste d'événements (EventCard).
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  int _segmentIndex = 0;
  EventType? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(discoverEventsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
          data: (events) {
            final filtered = _applyFilters(events);

            return ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.pageTop,
                bottom: AppSpacing.bottomClearanceWithNav,
              ),
              children: [
                _Header(
                  userName: currentUser.fullName,
                  onAvatarTap: () => context.go(AppRoutes.profile),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SegmentedControl(
                  selectedIndex: _segmentIndex,
                  onChanged: (index) async {
                    if (index == 2) {
                      // Create → écran de création d'événement (route plein-écran)
                      final isCreated = await context.push<bool>(
                        AppRoutes.eventCreate,
                      );
                      if (isCreated == true) {
                        ref.invalidate(discoverEventsProvider);
                      }
                      return;
                    }
                    setState(() => _segmentIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Bonjour 👋',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                ),
                Text(
                  'Que diriez-vous d’un bon\névénement ?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 32,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSearchField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoryChips(
                  selected: _selectedCategory,
                  onChanged: (category) =>
                      setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.search_off,
                    title: 'Aucun événement trouvé',
                    subtitle: 'Essayez une autre recherche ou une autre '
                        'catégorie.',
                  )
                else
                  ...filtered.map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: EventCard(event: event),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Event> _applyFilters(List<Event> events) {
    final query = _searchController.text.trim().toLowerCase();

    return events.where((event) {
      final matchesQuery = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.brandName.toLowerCase().contains(query) ||
          event.eventPlace.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == null ||
          event.type == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }
}

class _Header extends StatelessWidget {
  final String userName;
  final VoidCallback onAvatarTap;

  const _Header({required this.userName, required this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.confirmation_number, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'TicketPass',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        PressableScale(
          onTap: onAvatarTap,
          pressedScale: 0.9,
          child: UserAvatar(size: 44, name: userName),
        ),
      ],
    );
  }
}

/// Segment Buy / Sell / Create — spec §8 (pill verre, onglet actif `#148cfa`).
class _SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Buy', 'Sell', 'Create'];

    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isActive = index == selectedIndex;
          return Expanded(
            child: PressableScale(
              onTap: () => onChanged(index),
              pressedScale: 0.95,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppColors.textPrimary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Filtres par catégorie horizontal — spec §8 (7 chips) ;
/// restreints aux catégories de notre modèle ([EventType]).
class _CategoryChips extends StatelessWidget {
  final EventType? selected;
  final ValueChanged<EventType?> onChanged;

  const _CategoryChips({required this.selected, required this.onChanged});

  static const _labels = <EventType?, String>{
    null: 'Tous',
    EventType.sport: 'Sport',
    EventType.concert: 'Concerts',
    EventType.conference: 'Conférence',
    EventType.theatre: 'Théâtre',
    EventType.exposition: 'Exposition',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _labels.entries.map((entry) {
          final isActive = selected == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: PressableScale(
              onTap: () => onChanged(entry.key),
              pressedScale: 0.95,
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.glassSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}