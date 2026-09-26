import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_controller.dart';
import '../auth/user_profile.dart';
import '../money.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Seeded from the goal picked at signup — "Make Money" opens on Earn,
  /// "Get Things Done" on Browse. Only the starting side; both stay one tap away.
  late bool _earn =
      ref.read(currentProfileProvider)?.goal != UserGoal.getThingsDone;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            _header(),
            const SizedBox(height: 18),
            _toggle(),
            const SizedBox(height: 22),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: _earn ? _earnView() : _browseView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
          ),
          child: InitialsAvatar(
            ref.watch(currentProfileProvider)?.initials ?? '',
            size: 22,
            fontSize: 10,
          ),
        ),
        Image.asset(kLogoOnDark,
            height: 26, fit: BoxFit.contain, semanticLabel: 'Daala'),
        RoundIconButton(
            icon: Icons.search,
            semanticLabel: 'Search gigs',
            onTap: () => context.push('/search')),
      ],
    );
  }

  Widget _toggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.trackFill,
        borderRadius: BorderRadius.circular(AppRadius.track),
      ),
      child: Row(
        children: [
          _toggleTab('Earn Moola', _earn, () => setState(() => _earn = true)),
          _toggleTab('Browse Gigs', !_earn, () => setState(() => _earn = false)),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: active
              ? BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(AppRadius.segment),
                )
              : null,
          child: Text(
            label,
            style: AppText.label
                .copyWith(color: active ? AppColors.green : AppColors.inkMuted),
          ),
        ),
      ),
    );
  }

  // ── Earn view ──────────────────────────────────────────────
  // TODO(phase4): the nearby count, offers, earnings, and Gigs For You all come
  // from the gigs/offers/bookings collections. Until those exist, every figure
  // here is a true zero rather than a fixture.
  List<Widget> _earnView() {
    final suburb = ref.watch(currentProfileProvider)?.suburb;
    return [
      Column(
        children: [
          Text('Available Nearby', style: AppText.caption),
          const SizedBox(height: AppSpacing.xs),
          Text('0 Gigs', style: AppText.hero),
          const SizedBox(height: AppSpacing.xs),
          Text(suburb == null ? 'near you' : 'near $suburb',
              style: AppText.meta),
        ],
      ),
      const SizedBox(height: AppSpacing.xl4),
      Row(
        children: [
          Expanded(
            child: _statCard('My Offers', 'None yet', AppColors.ink),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: _statCard('This Week', '${formatZar(0)} earned',
                AppColors.cream,
                onTap: () => context.push('/wallet')),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.xl4),
      Text('Gigs For You', style: AppText.section),
      const SizedBox(height: AppSpacing.lg),
      EmptyState(
        'No Tasks near you yet',
        body: 'Tasks Buyers post near you will show up here. '
            'You can offer your own service in the meantime.',
        actionLabel: 'Post a Listing',
        onAction: () => context.push('/post/listing'),
      ),
    ];
  }

  Widget _statCard(String label, String value, Color valueColor,
      {VoidCallback? onTap}) {
    return GwCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 8),
          Text(value, style: AppText.section.copyWith(color: valueColor)),
        ],
      ),
    );
  }

  // ── Browse view ────────────────────────────────────────────
  List<Widget> _browseView() {
    return [
      // TODO(phase4): per-category rows of real Listings replace this.
      EmptyState(
        'No Listings to browse yet',
        body: 'Services Merchants offer near you will show up here. '
            'Post a Task and Merchants can apply to it.',
        actionLabel: 'Post a Task',
        onAction: () => context.push('/post/task'),
      ),
      const SizedBox(height: AppSpacing.xl4),
      Text('Categories', style: AppText.section),
      const SizedBox(height: AppSpacing.lg),
      _categoryGrid(),
    ];
  }

  Widget _categoryGrid() {
    // Per-category gig counts return with real gigs (Phase 4).
    const cats = [
      ('Home & Garden', AppColors.creamTintStrong),
      ('Moving & Hauling', AppColors.creamTint),
      ('Design & Creative', AppColors.creamTintStrong),
      ('Delivery & Errands', AppColors.creamTint),
      ('Cleaning', AppColors.creamTintStrong),
      ('Handyman', AppColors.creamTint),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        // Fixed extent, not an aspect ratio: deriving tile height from the
        // device width overflows the text on narrow screens.
        mainAxisExtent: 118,
      ),
      itemBuilder: (context, i) {
        final (name, tint) = cats[i];
        return GwCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flexible, so the tint block yields height to the labels
              // rather than the labels overflowing the tile.
              Expanded(child: Container(color: tint)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Text(name,
                    style: AppText.rowTitle.copyWith(fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }
}
