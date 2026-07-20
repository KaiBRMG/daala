import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';

/// Authenticated app shell: the four primary tabs plus the elevated orange
/// FAB that expands into a "Post" speed-dial (service / request / media).
///
/// Bar layout mirrors the design: [Home] [My Gigs] [ + ] [Inbox] [Profile].
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _fabOpen = false;

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() => setState(() => _fabOpen = false);

  void _goBranch(int index) {
    _closeFab();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.navigationShell.currentIndex;
    return Scaffold(
      backgroundColor: AppColors.screen,
      body: Stack(
        children: [
          Positioned.fill(child: widget.navigationShell),

          // Scrim behind the open speed-dial.
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_fabOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _fabOpen ? 1 : 0,
                child: GestureDetector(
                  onTap: _closeFab,
                  child: const ColoredBox(color: AppColors.scrim),
                ),
              ),
            ),
          ),

          // Speed-dial items.
          _SpeedDial(open: _fabOpen, onDismiss: _closeFab),

          // Floating pill nav.
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom * 0.4,
            child: _TabBar(
              currentIndex: current,
              fabOpen: _fabOpen,
              onTapBranch: _goBranch,
              onTapFab: _toggleFab,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.currentIndex,
    required this.fabOpen,
    required this.onTapBranch,
    required this.onTapFab,
  });

  final int currentIndex;
  final bool fabOpen;
  final ValueChanged<int> onTapBranch;
  final VoidCallback onTapFab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.tabbar),
        boxShadow: AppShadows.tabbar,
      ),
      child: Row(
        children: [
          _NavItem(
            label: 'Home',
            iconOutline: Icons.home_outlined,
            iconFilled: Icons.home_rounded,
            active: currentIndex == 0,
            onTap: () => onTapBranch(0),
          ),
          _NavItem(
            label: 'My Gigs',
            iconOutline: Icons.work_outline_rounded,
            iconFilled: Icons.work_rounded,
            active: currentIndex == 1,
            onTap: () => onTapBranch(1),
          ),
          Expanded(child: Center(child: _Fab(open: fabOpen, onTap: onTapFab))),
          _NavItem(
            label: 'Inbox',
            iconOutline: Icons.mail_outline_rounded,
            iconFilled: Icons.mail_rounded,
            active: currentIndex == 2,
            onTap: () => onTapBranch(2),
          ),
          _NavItem(
            label: 'Profile',
            iconOutline: Icons.person_outline_rounded,
            iconFilled: Icons.person_rounded,
            active: currentIndex == 3,
            onTap: () => onTapBranch(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.iconOutline,
    required this.iconFilled,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData iconOutline;
  final IconData iconFilled;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.green : AppColors.ink40;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active)
              Container(
                width: 34,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.greenTint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(iconFilled, size: 16, color: color),
              )
            else
              Icon(iconOutline, size: 18, color: color),
            const SizedBox(height: 3),
            Text(label, style: AppText.tabLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -13),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
            boxShadow: AppShadows.fab,
          ),
          child: AnimatedRotation(
            turns: open ? 0.125 : 0, // 45°
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add, size: 22, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}

class _SpeedDial extends StatelessWidget {
  const _SpeedDial({required this.open, required this.onDismiss});

  final bool open;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom * 0.4;
    final items = [
      (Icons.handyman_outlined, 'Post a service', 'service'),
      (Icons.help_outline_rounded, 'Post a request', 'request'),
      (Icons.image_outlined, 'Post to media', 'media'),
    ];
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16 + bottomInset + 68, // just above the nav bar
      child: IgnorePointer(
        ignoring: !open,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = items.length - 1; i >= 0; i--)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SpeedItem(
                  open: open,
                  delayMs: i * 30,
                  icon: items[i].$1,
                  label: items[i].$2,
                  onTap: () {
                    onDismiss();
                    context.push('/post/${items[i].$3}');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedItem extends StatelessWidget {
  const _SpeedItem({
    required this.open,
    required this.delayMs,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool open;
  final int delayMs;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 220 + delayMs),
      curve: Curves.easeOutBack,
      offset: open ? Offset.zero : const Offset(0, 0.4),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 180 + delayMs),
        opacity: open ? 1 : 0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.fromLTRB(14, 0, 18, 0),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              boxShadow: AppShadows.speedItem,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.greenTint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 15, color: AppColors.green),
                ),
                const SizedBox(width: 10),
                Text(label,
                    style: AppText.rowTitle.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
