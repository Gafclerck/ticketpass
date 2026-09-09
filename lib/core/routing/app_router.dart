import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/widgets/app_bottom_navigation_bar.dart';
import 'package:ticketpass/core/widgets/app_shell.dart';
import 'package:ticketpass/features/event/presentation/pages/create_event_page.dart';
import 'package:ticketpass/features/event/presentation/pages/edit_event_page.dart';
import 'package:ticketpass/features/home/presentation/screens/home_page.dart';
import 'package:ticketpass/features/event/presentation/screens/events_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/my_tickets_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/ticket_detail_page.dart';
import 'package:ticketpass/features/profile/presentation/screens/profile_page.dart';
import 'app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // routes racine hors StatefulShellBranch : pas de barre de navigation
    GoRoute(
      path: '${AppRoutes.ticketDetail}:id',
      builder: (context, state) => AppShell(
        child: TicketDetailPage(
          ticketId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventCreate,
      builder: (context, state) => const AppShell(child: CreateEventPage()),
    ),
    GoRoute(
      path: AppRoutes.eventEdit,
      builder: (context, state) {
        final eventId = state.uri.queryParameters['id'];
        if (eventId == null) {
          return const SizedBox.shrink();
        }
        return AppShell(child: EditEventPage(eventId: eventId));
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AppShell(
            child: Stack(
              children: [
                // navigationShell EST le widget qui affiche la page active
                navigationShell,
                // barre flottante dans un SafeArea : au-dessus de l'encoche
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      AppSpacing.navBarBottomOffset,
                    ),
                    child: AppBottomNavigationBar(
                      currentIndex: navigationShell.currentIndex,
                      onTap: (index) => navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      branches: [
        // index 0 - Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // index 1 - icone Ticket -> liste des evenements
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tickets,
              builder: (context, state) => const EventsPage(),
            ),
          ],
        ),
        // index 2 - icone Card -> mes billets
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.wallet,
              builder: (context, state) => const MyTicketsPage(),
            ),
          ],
        ),
        // index 3 - Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
