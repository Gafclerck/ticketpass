import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/widgets/app_bottom_navigation_bar.dart';
import 'package:ticketpass/features/home/presentation/screens/home_page.dart';
import 'package:ticketpass/features/event/presentation/screens/events_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/my_tickets_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/ticket_detail_page.dart';
import 'package:ticketpass/features/profile/presentation/screens/profile_page.dart';
import 'app_routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // routes hors StatefulShellBranch : pas de barre de navigation
    GoRoute(
      path: '${AppRoutes.ticketDetail}:id',
      builder: (context, state) => TicketDetailPage(
        ticketId: state.pathParameters['id']!,
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // navigationShell EST le widget qui affiche la page active
              navigationShell,
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AppBottomNavigationBar(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                ),
              ),
            ],
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
