import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../application/auth_providers.dart';

const int _digitCount = 4;
const int _resendSeconds = 30;

/// OTP verification (DESIGN.md §3.12): boxed digit inputs (auto-advance),
/// resend timer. Mock trigger: `0000` → invalid-code banner.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, this.phone});

  final String? phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _digits =
      List.generate(_digitCount, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(_digitCount, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _submitting = false;
  String? _bannerError;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _digits) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _digits.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < _digitCount) {
      setState(() => _bannerError = 'Enter the full $_digitCount-digit code');
      return;
    }
    setState(() {
      _submitting = true;
      _bannerError = null;
    });
    final error = await ref.read(authControllerProvider).verifyOtp(_code);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _bannerError = error;
    });
    if (error == null) context.go(RoutePaths.verifyIdentity);
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider).resendOtp();
    if (!mounted) return;
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code sent')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(color: DaalaColors.ink900)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          children: [
            Text('Enter the code',
                style:
                    DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
            const SizedBox(height: DaalaSpacing.s8),
            Text(
              'We sent a $_digitCount-digit code to '
              '${widget.phone ?? 'your phone'}.',
              style:
                  DaalaTextStyles.body.copyWith(color: DaalaColors.ink500),
            ),
            const SizedBox(height: DaalaSpacing.s32),
            if (_bannerError != null) ...[
              Container(
                padding: const EdgeInsets.all(DaalaSpacing.s12),
                decoration: BoxDecoration(
                  color: DaalaColors.statusDisputeBg,
                  borderRadius: BorderRadius.circular(DaalaRadius.rMd),
                ),
                child: Text(_bannerError!,
                    style: DaalaTextStyles.caption
                        .copyWith(color: DaalaColors.statusDispute)),
              ),
              const SizedBox(height: DaalaSpacing.s16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _digitCount; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DaalaSpacing.s8),
                    child: SizedBox(
                      width: DaalaSizes.inputHeight,
                      child: TextField(
                        controller: _digits[i],
                        focusNode: _nodes[i],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: DaalaTextStyles.h2
                            .copyWith(color: DaalaColors.ink900),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: DaalaColors.bgSecondary,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DaalaRadius.rMd),
                            borderSide: const BorderSide(
                                color: DaalaColors.borderDefault,
                                width: DaalaSizes.borderWidth),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(DaalaRadius.rMd),
                            borderSide: const BorderSide(
                                color: DaalaColors.brandGreen900,
                                width: DaalaSizes.borderWidthFocus),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              i < _digitCount - 1) {
                            _nodes[i + 1].requestFocus();
                          }
                          if (value.isEmpty && i > 0) {
                            _nodes[i - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DaalaSpacing.s16),
            Center(
              child: _secondsLeft > 0
                  ? Text('Resend code in ${_secondsLeft}s',
                      style: DaalaTextStyles.caption
                          .copyWith(color: DaalaColors.ink500))
                  : DaalaButton(
                      label: 'Resend code',
                      variant: DaalaButtonVariant.tertiary,
                      expand: false,
                      onPressed: _resend,
                    ),
            ),
            const SizedBox(height: DaalaSpacing.s24),
            DaalaButton(
                label: 'Verify', loading: _submitting, onPressed: _verify),
          ],
        ),
      ),
    );
  }
}
