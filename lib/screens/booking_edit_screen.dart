import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../widgets/ui.dart';

/// Presented as a modal sheet over a scrim (route `/booking/edit`).
class BookingEditScreen extends StatefulWidget {
  const BookingEditScreen({super.key});

  @override
  State<BookingEditScreen> createState() => _BookingEditScreenState();
}

class _BookingEditScreenState extends State<BookingEditScreen> {
  bool _recurring = true;
  bool _reminder = true;
  bool _autoConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const ColoredBox(color: AppColors.scrim),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88),
              decoration: const BoxDecoration(
                color: AppColors.screen,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              ),
              padding: EdgeInsets.fromLTRB(
                  18, 20, 18, 40 + MediaQuery.of(context).padding.bottom),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('Cancel',
                              style: AppText.tag.copyWith(
                                  fontSize: 15, color: AppColors.green)),
                        ),
                        Text('Edit Booking',
                            style: AppText.appBarTitle.copyWith(fontSize: 17)),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text('Done',
                              style: AppText.tag.copyWith(
                                  fontSize: 15, color: AppColors.ink40)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _valueRow('Booking Date', '12 Jul 2026'),
                    const SizedBox(height: 12),
                    _toggleRow('Recurring', _recurring,
                        (v) => setState(() => _recurring = v)),
                    const SizedBox(height: 12),
                    _valueRow('Frequency', 'Weekly'),
                    const SizedBox(height: 12),
                    _toggleRow('Reminder', _reminder,
                        (v) => setState(() => _reminder = v)),
                    const SizedBox(height: 12),
                    _toggleRow('Auto-confirm Helper', _autoConfirm,
                        (v) => setState(() => _autoConfirm = v)),
                    const SizedBox(height: 20),
                    Text(
                      'Helpers are notified as soon as you confirm a booking, typically within a few minutes.',
                      textAlign: TextAlign.center,
                      style: AppText.body.copyWith(
                          fontSize: 12, height: 1.6, color: AppColors.ink55),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowCard(Widget trailing, String label) {
    return GwCard(
      shadow: AppShadows.soft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppText.metaStrong
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
          trailing,
        ],
      ),
    );
  }

  Widget _valueRow(String label, String value) {
    return _rowCard(
      Text(value,
          style: AppText.metaStrong.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink55)),
      label,
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return _rowCard(_GwSwitch(value: value, onChanged: onChanged), label);
  }
}

/// Pill toggle matching the design (green on, grey off; 46×28 track).
class _GwSwitch extends StatelessWidget {
  const _GwSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 46,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.green : AppColors.ink15,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
                color: AppColors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
