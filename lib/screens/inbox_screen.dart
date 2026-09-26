import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          padding: const EdgeInsets.only(top: 18, bottom: 120),
          children: [
            Text('Inbox', style: AppText.screenTitleLg),
            const SizedBox(height: 18),
            // TODO(phase5): Firestore-backed threads replace this.
            const EmptyState(
              'No messages yet',
              body: 'When you apply to a Task or someone books your Listing, '
                  'your chat with them shows up here.',
            ),
          ],
        ),
      ),
    );
  }
}
