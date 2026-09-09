import 'package:flutter/material.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/core/widgets/status_badge.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_status.dart';

/// Carte événement — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.3 (variante défaut).
///
/// Pleine largeur, 280px de haut, radius 32, bordure primary/15, image de
/// couverture + dégradé, titre en Playfair, sous-titre date · lieu.
/// La route de détail (EventDetailScreen) n'étant pas encore implémentée,
/// `onTap` reste optionnel.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({super.key, required this.event, this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(event.eventDate);

    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          // image de marque absente en mock : fond bleuté en attendant
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
            // dégradé de fond (to top) : opaque → transparent
            DecoratedBox(
              decoration: const BoxDecoration(
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${event.maxPlaces} places',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: event.status.label,
                          variant: _statusVariant(event.status),
                        ),
                      ],
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

  static StatusBadgeVariant _statusVariant(EventStatus status) {
    return switch (status) {
      EventStatus.upcoming => StatusBadgeVariant.green,
      EventStatus.ongoing => StatusBadgeVariant.blue,
      EventStatus.passed => StatusBadgeVariant.gray,
    };
  }
}