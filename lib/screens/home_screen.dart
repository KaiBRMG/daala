import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../money.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _earn = true;

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
            boxShadow: AppShadows.soft,
          ),
          child: const InitialsAvatar('JD', size: 22, fontSize: 10),
        ),
        Image.asset('assets/images/daala-logo.png',
            height: 26, fit: BoxFit.contain),
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
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.segment),
                  boxShadow: AppShadows.soft,
                )
              : null,
          child: Text(
            label,
            style: AppText.label
                .copyWith(color: active ? AppColors.green : AppColors.ink55),
          ),
        ),
      ),
    );
  }

  // ── Earn view ──────────────────────────────────────────────
  List<Widget> _earnView() {
    return [
      Column(
        children: [
          Text('Available Nearby', style: AppText.caption),
          const SizedBox(height: 6),
          Text('24 Gigs', style: AppText.hero),
          const SizedBox(height: 6),
          Text('within 5km of Melville', style: AppText.meta),
        ],
      ),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: _statCard('My Offers', '3 pending replies', AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard('This Week', '${formatZar(41000)} earned',
                AppColors.orange,
                onTap: () => context.push('/wallet')),
          ),
        ],
      ),
      const SizedBox(height: 14),
      GwCard(
        onTap: () => context.push('/booking/edit'),
        child: Row(
          children: [
            _iconCircle(Icons.event, AppColors.orange, AppColors.orangeTint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Garden cleanup — tomorrow 9am',
                      style: AppText.rowTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Booked with Marlo T.', style: AppText.meta),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const StatusPill('Confirmed'),
          ],
        ),
      ),
      const SizedBox(height: 22),
      Text('Gigs For You', style: AppText.section),
      const SizedBox(height: 12),
      for (final gig in _gigsForYou) ...[
        _gigRow(gig),
        if (gig != _gigsForYou.last) const SizedBox(height: 10),
      ],
    ];
  }

  static const List<_Gig> _gigsForYou = [
    _Gig('Assemble flatpack shelving', '1.2km · posted 2h ago', 6500,
        'Thabo M.', 'TM', '4.9'),
    _Gig('Logo design for cafe', 'Remote · posted 5h ago', 30000, 'Naledi K.',
        'NK', '5.0'),
    _Gig('Grocery delivery run', '0.8km · posted 20m ago', 2800, 'Sipho D.',
        'SD', '4.8'),
  ];

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

  Widget _iconCircle(IconData icon, Color fg, Color bg) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: fg),
    );
  }

  Widget _gigRow(_Gig gig) {
    return GwCard(
      onTap: () => context.push('/gig'),
      child: Row(
        children: [
          const PhotoPlaceholder(width: 52, height: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gig.title,
                    style: AppText.rowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InitialsAvatar(gig.initials, size: 20, fontSize: 9),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(gig.poster,
                          style: AppText.caption.copyWith(color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.orange),
                    const SizedBox(width: 2),
                    Text(gig.rating,
                        style: AppText.caption.copyWith(color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(gig.meta, style: AppText.meta),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(formatZar(gig.priceMinor), style: AppText.price),
        ],
      ),
    );
  }

  // ── Browse view ────────────────────────────────────────────
  List<Widget> _browseView() {
    return [
      _sectionHeader('Home & Garden'),
      const SizedBox(height: 12),
      _horizontalRow([
        ('Weekly hedge trim', '2.4km', formatZar(4500)),
        ('Garden bed weeding', '1.6km', formatZar(3800)),
        ('Lawn mowing', '0.9km', formatZar(5500)),
      ]),
      const SizedBox(height: 24),
      _sectionHeader('Delivery & Errands'),
      const SizedBox(height: 12),
      _horizontalRow([
        ('Grocery delivery run', '0.8km', formatZar(2800)),
        ('Pharmacy pickup', '1.1km', formatZar(1800)),
        ('Post office run', '2.0km', formatZar(2200)),
      ]),
      const SizedBox(height: 24),
      Text('Categories', style: AppText.section),
      const SizedBox(height: 12),
      _categoryGrid(),
    ];
  }

  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.section),
        Pressable(
          onTap: () => context.push('/search'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text('See all',
                style: AppText.tag.copyWith(color: AppColors.green)),
          ),
        ),
      ],
    );
  }

  Widget _horizontalRow(List<(String, String, String)> items) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final (title, dist, price) = items[i];
          return GwCard(
            padding: EdgeInsets.zero,
            clip: true,
            onTap: () => context.push('/gig'),
            child: SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PhotoPlaceholder(height: 88, radius: 0),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.rowTitle.copyWith(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(dist,
                            style: AppText.meta.copyWith(fontSize: 11)),
                        const SizedBox(height: 6),
                        Text(price,
                            style: AppText.price.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryGrid() {
    const cats = [
      ('Home & Garden', '38 gigs', AppColors.greenTintStrong),
      ('Moving & Hauling', '21 gigs', AppColors.orangeTint),
      ('Design & Creative', '17 gigs', AppColors.greenTintStrong),
      ('Delivery & Errands', '54 gigs', AppColors.orangeTint),
      ('Cleaning', '12 gigs', AppColors.greenTintStrong),
      ('Handyman', '9 gigs', AppColors.orangeTint),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 158 / 120,
      ),
      itemBuilder: (context, i) {
        final (name, count, tint) = cats[i];
        return GwCard(
          padding: EdgeInsets.zero,
          clip: true,
          shadow: AppShadows.category,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 76, color: tint),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppText.rowTitle.copyWith(fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(count, style: AppText.meta.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mock gig fixture for the "Gigs For You" list. Every gig carries a named
/// human and rating so the list reads as people, not a classifieds wall
/// (DESIGN.md: "Trust is the interface").
class _Gig {
  const _Gig(this.title, this.meta, this.priceMinor, this.poster, this.initials,
      this.rating);

  final String title;
  final String meta;
  final int priceMinor;
  final String poster;
  final String initials;
  final String rating;
}
