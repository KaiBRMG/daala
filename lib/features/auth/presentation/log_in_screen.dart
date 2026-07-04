import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_input.dart';
import '../application/auth_providers.dart';

/// Log In (DESIGN.md §3.12). Mock trigger: password `wrong` → error banner.
class LogInScreen extends ConsumerStatefulWidget {
  const LogInScreen({super.key});

  @override
  ConsumerState<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends ConsumerState<LogInScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _identifierError;
  String? _passwordError;
  String? _bannerError;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _bannerError = null;
      _identifierError = AuthValidators.identifier(_identifier.text);
      _passwordError =
          _password.text.isEmpty ? 'Password is required' : null;
    });
    if (_identifierError != null || _passwordError != null) return;

    setState(() => _submitting = true);
    final error = await ref.read(authControllerProvider).logIn(
        identifier: _identifier.text, password: _password.text);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _bannerError = error;
    });
    if (error == null) context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(color: DaalaColors.ink900)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          children: [
            Text('Welcome back',
                style:
                    DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
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
            DaalaInput(
              label: 'Phone or email',
              hint: '+27 phone number or email',
              controller: _identifier,
              keyboardType: TextInputType.emailAddress,
              errorText: _identifierError,
            ),
            const SizedBox(height: DaalaSpacing.s16),
            DaalaInput(
              label: 'Password',
              controller: _password,
              obscureText: _obscure,
              errorText: _passwordError,
              suffix: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: DaalaSizes.iconLg,
                    color: DaalaColors.ink500),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            const SizedBox(height: DaalaSpacing.s8),
            Align(
              alignment: Alignment.centerLeft,
              child: DaalaButton(
                label: 'Forgot password',
                variant: DaalaButtonVariant.tertiary,
                expand: false,
                // TODO(spec): password reset flow deferred to Phase 2.
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Password reset arrives in a later phase.'))),
              ),
            ),
            const SizedBox(height: DaalaSpacing.s16),
            DaalaButton(
                label: 'Log in', loading: _submitting, onPressed: _submit),
            const SizedBox(height: DaalaSpacing.s8),
            DaalaButton(
              label: 'New to Daala? Create an account',
              variant: DaalaButtonVariant.tertiary,
              onPressed: () => context.push(RoutePaths.signup),
            ),
          ],
        ),
      ),
    );
  }
}
