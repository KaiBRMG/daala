import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../../../core/widgets/daala_input.dart';
import '../application/auth_providers.dart';

/// Sign Up (DESIGN.md §3.12): full name, phone (ZA +27) or email,
/// password (show/hide), T&Cs checkbox → OTP.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _acceptedTerms = false;
  bool _submitting = false;
  String? _nameError;
  String? _identifierError;
  String? _passwordError;
  String? _termsError;

  @override
  void dispose() {
    _name.dispose();
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = AuthValidators.requiredField(_name.text, 'Full name');
      _identifierError = AuthValidators.identifier(_identifier.text);
      _passwordError = AuthValidators.password(_password.text);
      _termsError =
          _acceptedTerms ? null : 'Please accept the terms to continue';
    });
    if (_nameError != null ||
        _identifierError != null ||
        _passwordError != null ||
        _termsError != null) {
      return;
    }

    setState(() => _submitting = true);
    await ref.read(authControllerProvider).signUp(
          fullName: _name.text,
          identifier: _identifier.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    context.push(
        '${RoutePaths.otp}?phone=${Uri.encodeComponent(_identifier.text)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: DaalaColors.ink900),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          children: [
            Text('Create your account',
                style:
                    DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
            const SizedBox(height: DaalaSpacing.s8),
            Text('One account for getting things done and earning.',
                style:
                    DaalaTextStyles.body.copyWith(color: DaalaColors.ink500)),
            const SizedBox(height: DaalaSpacing.s32),
            DaalaInput(
              label: 'Full name',
              hint: 'e.g. Thandi Mokoena',
              controller: _name,
              errorText: _nameError,
            ),
            const SizedBox(height: DaalaSpacing.s16),
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
              hint: 'At least 6 characters',
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
            const SizedBox(height: DaalaSpacing.s16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) =>
                      setState(() => _acceptedTerms = v ?? false),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: DaalaSpacing.s12),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: DaalaTextStyles.caption
                          .copyWith(color: DaalaColors.ink700),
                    ),
                  ),
                ),
              ],
            ),
            if (_termsError != null)
              Text(_termsError!,
                  style: DaalaTextStyles.caption
                      .copyWith(color: DaalaColors.statusDispute)),
            const SizedBox(height: DaalaSpacing.s24),
            DaalaButton(
                label: 'Create account',
                loading: _submitting,
                onPressed: _submit),
            const SizedBox(height: DaalaSpacing.s8),
            DaalaButton(
              label: 'Already have an account? Log in',
              variant: DaalaButtonVariant.tertiary,
              onPressed: () => context.push(RoutePaths.login),
            ),
          ],
        ),
      ),
    );
  }
}
