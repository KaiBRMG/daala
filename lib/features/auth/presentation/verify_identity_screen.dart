import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/daala_button.dart';
import '../application/auth_providers.dart';

/// Verify Identity — KYC prompt (DESIGN.md §3.12). Mock success only;
/// real VerifyNow integration is deferred to Phase 8.
class VerifyIdentityScreen extends ConsumerStatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  ConsumerState<VerifyIdentityScreen> createState() =>
      _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState
    extends ConsumerState<VerifyIdentityScreen> {
  bool _submitting = false;

  Future<void> _verifyNow() async {
    setState(() => _submitting = true);
    await ref.read(authControllerProvider).verifyIdentityNow();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("You're verified — badge unlocked")));
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DaalaSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: DaalaSpacing.s48),
              const Icon(Icons.verified_user_outlined,
                  size: DaalaSizes.emptyStateIcon,
                  color: DaalaColors.brandGreen900),
              const SizedBox(height: DaalaSpacing.s24),
              Text('Verify your identity',
                  textAlign: TextAlign.center,
                  style:
                      DaalaTextStyles.h1.copyWith(color: DaalaColors.ink900)),
              const SizedBox(height: DaalaSpacing.s12),
              Text(
                'Daala holds money safely in Escrow while gigs get done. '
                'To keep everyone safe (and to meet FICA rules), we check '
                'your SA ID once. It takes about two minutes and unlocks '
                'your verification badge.',
                textAlign: TextAlign.center,
                style: DaalaTextStyles.bodyLg
                    .copyWith(color: DaalaColors.ink700),
              ),
              const Spacer(),
              DaalaButton(
                  label: 'Verify now',
                  loading: _submitting,
                  onPressed: _verifyNow),
              const SizedBox(height: DaalaSpacing.s8),
              DaalaButton(
                label: 'Skip for now',
                variant: DaalaButtonVariant.tertiary,
                onPressed: () => context.go(RoutePaths.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
