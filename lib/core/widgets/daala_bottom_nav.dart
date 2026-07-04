import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Persistent bottom nav (DESIGN.md §2.2): 5 items, labels always visible,
/// center Post FAB is the only orange fill in the shell.
///
/// Indices: 0 Home · 1 Dashboard · 2 Post · 3 Messages · 4 Profile.
class DaalaBottomNav extends StatelessWidget {
  const DaalaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messagesUnread = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool messagesUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DaalaColors.bgPrimary,
        border: Border(
          top: BorderSide(
              color: DaalaColors.borderSubtle,
              width: DaalaSizes.borderWidth),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: DaalaSizes.bottomNavHeight,
          child: Row(
            children: [
              _item(0, 'Home', Icons.home_outlined, Icons.home),
              _item(1, 'Dashboard', Icons.dashboard_outlined,
                  Icons.dashboard),
              _postFab(),
              _item(3, 'Messages', Icons.chat_bubble_outline,
                  Icons.chat_bubble,
                  dot: messagesUnread),
              _item(4, 'Profile', Icons.person_outline, Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int index, String label, IconData icon, IconData activeIcon,
      {bool dot = false}) {
    final active = index == currentIndex;
    final color = active ? DaalaColors.brandGreen900 : DaalaColors.ink500;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(active ? activeIcon : icon,
                    color: color, size: DaalaSizes.iconLg),
                if (dot)
                  Positioned(
                    top: 0,
                    right: -DaalaSpacing.s2,
                    child: Container(
                      width: DaalaSpacing.s8,
                      height: DaalaSpacing.s8,
                      decoration: const BoxDecoration(
                        color: DaalaColors.accentOrange500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DaalaSpacing.s2),
            Text(label,
                style: DaalaTextStyles.overline.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _postFab() {
    return Expanded(
      child: Center(
        child: Material(
          color: DaalaColors.accentOrange500,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            highlightColor: DaalaColors.accentOrange600,
            splashColor: Colors.transparent,
            onTap: () => onTap(2),
            child: const SizedBox(
              width: DaalaSizes.postFabSize,
              height: DaalaSizes.postFabSize,
              child: Icon(Icons.add,
                  color: DaalaColors.onBrand, size: DaalaSizes.iconLg),
            ),
          ),
        ),
      ),
    );
  }
}
