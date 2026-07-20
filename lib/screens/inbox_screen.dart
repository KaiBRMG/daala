import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  static const _threads = [
    ('MT', 'Marlo T.', '2m', 'Sounds good, see you at 9am tomorrow!', true),
    (null, 'Ana R.', '1h', 'Thanks again for the quick turnaround on the shelving!', false),
    (null, 'Theo B.', 'Yesterday', 'Can you send over the final logo files?', false),
    (null, 'Groundwork Support', '2d', 'Your withdrawal of \$200.00 has been processed.', false),
  ];

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
            for (var i = 0; i < _threads.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _row(_threads[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row((String?, String, String, String, bool) t) {
    final (initials, name, time, preview, unread) = t;
    return GwCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (initials != null)
            InitialsAvatar(initials, size: 44)
          else
            const PhotoPlaceholder(width: 44, height: 44, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: AppText.rowTitle),
                    Text(time,
                        style: AppText.meta.copyWith(
                            fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink40)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(
                        fontSize: 13, height: 1.2, color: AppColors.ink50)),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  color: AppColors.orange, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}
