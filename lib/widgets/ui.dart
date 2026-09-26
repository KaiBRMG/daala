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

/// Which brand fill a [GwButton] wears.
///
/// The One-Action Orange Rule (DESIGN.md §2): [GwButtonTone.orange] leads the
/// single forward action on a screen — never two on one screen.
/// [GwButtonTone.cream] carries committing and creating actions.
enum GwButtonTone { orange, cream }

/// The primary CTA pill: 56 tall, 28 radius, a flat brand fill with a centred
/// w700/16 green label. No glow — the fill alone carries the weight.
///
/// Ships all four states DESIGN.md §5 specifies — resting, pressed (via
/// [Pressable]), disabled (the raised surface with an inkMuted label), and
/// loading (a green spinner in a pill that keeps its width so nothing reflows).
class GwButton extends StatelessWidget {
  const GwButton({
    super.key,
    required this.label,
    this.onTap,
    this.tone = GwButtonTone.orange,
    this.loading = false,
    this.icon,
  });

  final String label;

  /// `null` renders the disabled state. So does [loading].
  final VoidCallback? onTap;
  final GwButtonTone tone;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    final fill = tone == GwButtonTone.orange ? AppColors.orange : AppColors.cream;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Disabled drops to the raised surface: a lighter tone of the
            // ground, never a grey.
            color: enabled ? fill : AppColors.raised,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.green),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18,
                        color: enabled ? AppColors.green : AppColors.inkMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      label,
                      style: AppText.section.copyWith(
                        color: enabled ? AppColors.green : AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The quiet counterpart to [GwButton]: a cream w700/15 text action with a
/// 48dp-tall hit area. Used for "Log in with Email", "Change number", "Skip" —
/// secondary routes that must not compete with the orange CTA.
class GwTextAction extends StatelessWidget {
  const GwTextAction({
    super.key,
    required this.label,
    this.onTap,
    this.color = AppColors.cream,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: Pressable(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.value.copyWith(
              fontWeight: FontWeight.w700,
              color: enabled ? color : AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// An inline message under a field or CTA.
///
/// DESIGN.md §5: "this system has no red; errors are stated in words, not alarm
/// colour." So an error and a hint differ only in weight and in whether a small
/// cream glyph leads — the sentence carries the meaning.
class InlineNotice extends StatelessWidget {
  const InlineNotice(this.message, {super.key, this.emphasis = false});

  final String message;

  /// `true` for errors and things the user must act on: adds the leading glyph
  /// and steps the text up to inkBody.
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: emphasis,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emphasis) ...[
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              message,
              style: AppText.body.copyWith(
                color: emphasis ? AppColors.inkBody : AppColors.inkMuted,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A thin determinate progress rail for a multi-step flow.
///
/// Deliberately not a Material `LinearProgressIndicator`: this is a 4px track at
/// 7% cream with a cream fill and fully rounded ends, matching the segmented
/// toggle's track treatment rather than introducing a second progress vocabulary.
class ProgressRail extends StatelessWidget {
  const ProgressRail({super.key, required this.progress});

  /// 0..1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      value: '${(progress * 100).round()} percent complete',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.status),
        child: Container(
          height: 4,
          color: AppColors.trackFill,
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: const ColoredBox(color: AppColors.cream),
          ),
        ),
      ),
    );
  }
}

/// The design's two-option selector: side-by-side pills at 22 radius. Selected
/// is transparent with a 2px cream outline (the one sanctioned stroke in this
/// system); unselected sits on a 7%-cream track with inkMuted text.
class TwoOptionSelector<T> extends StatelessWidget {
  const TwoOptionSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.subtitleBuilder,
  });

  /// Ordered `(value, label)` pairs — exactly two.
  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onChanged;

  /// Optional supporting line under each label.
  final String Function(T value)? subtitleBuilder;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the Row a bounded height to stretch into. Without
    // it, `stretch` inherits the unbounded height a ListView hands its children
    // and the whole scroll view fails to lay out. Two children only, so the
    // extra intrinsic pass is negligible.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _Option(
                label: options[i].$2,
                subtitle: subtitleBuilder?.call(options[i].$1),
                selected: options[i].$1 == selected,
                onTap: () => onChanged(options[i].$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Pressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.trackFill,
            borderRadius: BorderRadius.circular(AppRadius.track),
            border: selected
                ? Border.all(color: AppColors.cream, width: 2)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppText.metaStrong.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.cream : AppColors.inkMuted,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppText.meta.copyWith(fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The flat card: one tonal step above the ground, radius 16, no shadow and no
/// border. The tone difference alone makes it a discrete object.
class GwCard extends StatelessWidget {
  const GwCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.color = AppColors.card,
    this.clip = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final bool clip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: child,
    );
    return Pressable(onTap: onTap, child: content);
  }
}

/// Circular initials avatar on the raised tone (the current user & posters).
/// Tonal rather than a bright fill, so a list of people doesn't become a column
/// of cream dots competing with the money.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.initials,
      {super.key, this.size = 44, this.fontSize = 14, this.bg = AppColors.raised});

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
              color: AppColors.cream,
              fontSize: fontSize,
              fontWeight: FontWeight.w800)),
    );
  }
}

/// Tonal placeholder box standing in for a photo/thumbnail (data-ph in design).
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
    this.bg = AppColors.creamTint,
    this.fg = AppColors.cream,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
  });

  final String label;
  final Color bg;
  final Color fg;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(label, style: AppText.tag.copyWith(color: fg)),
    );
  }
}

/// Lifecycle status pill (`Confirmed`, `In progress`). Positive states are a
/// solid cream pill with green text — the brightest small object on a row,
/// because trust cues are first-class. Neutral in-flight states use the cream
/// tint with inkBody text. There is no red in this system (DESIGN.md §2).
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.positive = true});

  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: positive ? AppColors.cream : AppColors.creamTint,
        borderRadius: BorderRadius.circular(AppRadius.status),
      ),
      child: Text(
        label,
        style: AppText.status
            .copyWith(color: positive ? AppColors.green : AppColors.inkBody),
      ),
    );
  }
}

/// DESIGN.md §5's empty state: a plain Title line naming what will appear, and
/// the screen's own CTA to start it. Shown wherever a list has no rows yet —
/// never filler content standing in for data that doesn't exist.
///
/// The action is the quiet [GwTextAction], not the orange pill: an empty list
/// is not the screen's one forward action (The One-Action Orange Rule).
class EmptyState extends StatelessWidget {
  const EmptyState(
    this.title, {
    super.key,
    this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return GwCard(
      padding: const EdgeInsets.all(AppSpacing.xl4),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: AppText.cardTitle),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: AppText.meta.copyWith(height: 1.45),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            GwTextAction(label: actionLabel!, onTap: onAction),
          ],
        ],
      ),
    );
  }
}
