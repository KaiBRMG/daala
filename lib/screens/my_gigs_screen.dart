import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class MyGigsScreen extends StatefulWidget {
  const MyGigsScreen({super.key});

  @override
  State<MyGigsScreen> createState() => _MyGigsScreenState();
}

class _MyGigsScreenState extends State<MyGigsScreen> {
  int _tab = 0;
  static const _tabs = ['Upcoming', 'Applied', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          padding: const EdgeInsets.only(top: 18, bottom: 120),
          children: [
            Text('My Gigs', style: AppText.screenTitleLg),
            const SizedBox(height: 18),
            _segmented(),
            const SizedBox(height: 22),
            // TODO(phase4): bookings and offers stream in here per tab.
            _emptyForTab(),
          ],
        ),
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.trackFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: _tab == i
                      ? BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(AppRadius.segment),
                        )
                      : null,
                  child: Text(
                    _tabs[i],
                    style: AppText.label.copyWith(
                      fontWeight: _tab == i ? FontWeight.w700 : FontWeight.w600,
                      color: _tab == i ? AppColors.green : AppColors.inkMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyForTab() {
    return switch (_tab) {
      0 => EmptyState(
          'No upcoming gigs',
          body: 'Booked work — yours or someone you hired — shows up here.',
          actionLabel: 'Post a Task',
          onAction: () => context.push('/post/task'),
        ),
      1 => EmptyState(
          'No applications yet',
          body: 'Tasks you offer to do show up here while you wait to hear back.',
          actionLabel: 'Browse Gigs',
          onAction: () => context.go('/home'),
        ),
      _ => const EmptyState(
          'No completed gigs yet',
          body: 'Finished work and its payouts show up here.',
        ),
    };
  }
}
