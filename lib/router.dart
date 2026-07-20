import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/booking_edit_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/gig_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/my_gigs_screen.dart';
import 'screens/post_gig_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';
import 'widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/my-gigs', builder: (_, _) => const MyGigsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/inbox', builder: (_, _) => const InboxScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ]),
      ],
    ),

    // ── Pushed routes (over the shell) ──
    GoRoute(path: '/browse', builder: (_, _) => const BrowseScreen()),
    GoRoute(path: '/gig', builder: (_, _) => const GigDetailScreen()),
    GoRoute(path: '/post/:kind', builder: (_, _) => const PostGigScreen()),
    GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),

    // Modal sheet (transparent, shell stays visible behind the scrim).
    GoRoute(
      path: '/booking/edit',
      pageBuilder: (context, state) => CustomTransitionPage(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 220),
        child: const BookingEditScreen(),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    ),
  ],
);
