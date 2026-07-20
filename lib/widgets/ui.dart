import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Wraps a tappable surface with the design's pressed feedback: a 0.97 scale
/// over 120ms (DESIGN.md §5 "Pressed"). Returns [child] untouched when there is
/// no [onTap], and skips the scale under a reduced-motion preference.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _down && !reduceMotion ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// White rounded card matching `.card` in the design (radius 22 + soft shadow).
class GwCard extends StatelessWidget {
  const GwCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.color = AppColors.card,
    this.shadow = AppShadows.card,
    this.clip = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final List<BoxShadow> shadow;
  final bool clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: shadow,
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: child,
    );
    return Pressable(onTap: onTap, child: content);
  }
}

/// Circular initials avatar on deep green (as used for the current user & posters).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials,
      {super.key, this.size = 44, this.fontSize = 14, this.bg = AppColors.green});

  final String initials;
  final double size;
  final double fontSize;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(initials,
          style: AppText.rowTitle.copyWith(
              color: AppColors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800)),
    );
  }
}

/// Khaki placeholder box standing in for a photo/thumbnail (data-ph in design).
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.radius = 14,
    this.color = AppColors.placeholder,
  });

  final double? width;
  final double? height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Small circular round icon button used in headers (back / bell / add).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.semanticLabel,
    this.size = 44,
    this.iconSize = 18,
    this.bg = AppColors.card,
    this.iconColor = AppColors.ink,
  });

  final IconData icon;
  final VoidCallback? onTap;

  /// Spoken label for this icon-only control (screen readers announce nothing
  /// from a bare glyph). Omit only for a purely decorative button.
  final String? semanticLabel;
  final double size;
  final double iconSize;
  final Color bg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft,
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

/// Simulated iOS status bar (9:41 + signal/battery) — matches the mockup chrome.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, this.color = AppColors.ink});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 8, 26, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41',
              style: AppText.metaStrong
                  .copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 16, color: color),
              const SizedBox(width: 5),
              Icon(Icons.wifi, size: 16, color: color),
              const SizedBox(width: 5),
              Icon(Icons.battery_full, size: 18, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pill tag (e.g. "Moving · One-time", skill chips). Filled tint by default.
class TagPill extends StatelessWidget {
  const TagPill(
    this.label, {
    super.key,
    this.bg = AppColors.greenTint,
    this.fg = AppColors.green,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    this.shadow,
  });

  final String label;
  final Color bg;
  final Color fg;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.tag),
        boxShadow: shadow,
      ),
      child: Text(label, style: AppText.tag.copyWith(color: fg)),
    );
  }
}

/// Lifecycle status pill (`Confirmed`, `In progress`). Positive states use the
/// green tint with green text; neutral in-flight states use a hairline fill
/// with ink-55 text. There is no red in this system (DESIGN.md §2).
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.positive = true});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? AppColors.greenTint : AppColors.divider,
        borderRadius: BorderRadius.circular(AppRadius.status),
      ),
      child: Text(
        label,
        style: AppText.status
            .copyWith(color: positive ? AppColors.green : AppColors.ink55),
      ),
    );
  }
}
