import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/route_paths.dart';
import '../theme/tokens.dart';
import 'daala_list_row.dart';

/// The center-FAB "Create chooser sheet" (DESIGN.md §2.1 [Tab 3]).
void showCreateChooserSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(DaalaSpacing.s16,
                DaalaSpacing.s24, DaalaSpacing.s16, DaalaSpacing.s8),
            child: Text('Post a gig',
                style:
                    DaalaTextStyles.h3.copyWith(color: DaalaColors.ink900)),
          ),
          DaalaListRow(
            leading: const LeadingCircleIcon(icon: Icons.checklist_outlined),
            title: 'Post a Gig Request',
            subtitle: 'Get something done — Merchants send you Offers',
            trailing: const Icon(Icons.chevron_right,
                color: DaalaColors.ink500, size: DaalaSizes.iconLg),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(RoutePaths.createGigRequest);
            },
          ),
          DaalaListRow(
            leading: const LeadingCircleIcon(icon: Icons.storefront_outlined),
            title: 'Post a Gig Post',
            subtitle: 'Advertise your services and earn',
            showDivider: false,
            trailing: const Icon(Icons.chevron_right,
                color: DaalaColors.ink500, size: DaalaSizes.iconLg),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(RoutePaths.createGigPost);
            },
          ),
          const SizedBox(height: DaalaSpacing.s16),
        ],
      ),
    ),
  );
}
