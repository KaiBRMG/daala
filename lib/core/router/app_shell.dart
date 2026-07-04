import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/create_chooser_sheet.dart';
import '../widgets/daala_bottom_nav.dart';

/// Authenticated shell — persistent bottom nav over the four tab branches.
/// Nav slot 2 (Post) opens the create chooser sheet instead of a branch.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const List<int> _branchToNav = [0, 1, 3, 4];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DaalaBottomNav(
        currentIndex: _branchToNav[navigationShell.currentIndex],
        // Mock conversations include unread messages (messaging fixtures).
        messagesUnread: true,
        onTap: (navIndex) {
          switch (navIndex) {
            case 0:
              navigationShell.goBranch(0,
                  initialLocation: navigationShell.currentIndex == 0);
            case 1:
              navigationShell.goBranch(1,
                  initialLocation: navigationShell.currentIndex == 1);
            case 2:
              showCreateChooserSheet(context);
            case 3:
              navigationShell.goBranch(2,
                  initialLocation: navigationShell.currentIndex == 2);
            case 4:
              navigationShell.goBranch(3,
                  initialLocation: navigationShell.currentIndex == 3);
          }
        },
      ),
    );
  }
}
