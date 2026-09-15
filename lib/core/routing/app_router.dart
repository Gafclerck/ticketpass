import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/widgets/app_bottom_navigation_bar.dart';
import 'package:ticketpass/core/widgets/app_shell.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';
import 'package:ticketpass/features/auth/presentation/screens/login_page.dart';
import 'package:ticketpass/features/auth/presentation/screens/register_page.dart';
import 'package:ticketpass/features/event/presentation/pages/create_event_page.dart';
import 'package:ticketpass/features/event/presentation/pages/edit_event_page.dart';
import 'package:ticketpass/features/home/presentation/screens/home_page.dart';
import 'package:ticketpass/features/event/presentation/screens/events_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/event_tickets_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/my_tickets_page.dart';
import 'package:ticketpass/features/ticket/presentation/screens/ticket_detail_page.dart';
import 'package:ticketpass/features/profile/presentation/screens/profile_page.dart';
import 'app_routes.dart';
import 'auth_redirect_notifier.dart';

/// UC14 — le routeur dépend de l'état d'auth, donc c'est un provider (pas un
/// simple `final` top-level) : `ref` permet de lire/écouter l'auth pour la
/// garde de route.
final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = AuthRedirectNotifier();
  // Une seule souscription au flux d'auth, partagée avec currentUserProvider
  // via ce même authStateChangesProvider — évite la race condition entre
  // deux souscriptions indépendantes à authStateChanges.
  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    next.whenData(authNotifier.update);
  }, fireImmediately: true);
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final isLoggedIn = authNotifier.currentUser != null;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Tant que le tout premier check Firebase n'est pas résolu, on
      // n'autorise que login/register — pas de flash sur une page protégée.
      if (!authNotifier.isReady) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (!isLoggedIn) {
        return isAuthRoute ? null : AppRoutes.login;
      }
      if (isLoggedIn && isAuthRoute) {
        return AppRoutes.home;
      }
      return null;
    },
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
      path: '${AppRoutes.eventTickets}:id',
      builder: (context, state) => AppShell(
        child: EventTicketsPage(
          eventId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const AppShell(child: LoginPage()),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const AppShell(child: RegisterPage()),
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
});
