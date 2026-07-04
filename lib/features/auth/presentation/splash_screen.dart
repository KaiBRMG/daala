import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/mock/mock_session.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/tokens.dart';

/// Brand load + mock auth check (DESIGN.md §3.13).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      final signedIn = ref.read(sessionProvider).signedIn;
      context.go(signedIn ? RoutePaths.home : RoutePaths.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DaalaColors.brandGreen900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Daala',
                style: DaalaTextStyles.display
                    .copyWith(color: DaalaColors.onBrand)),
            const SizedBox(height: DaalaSpacing.s8),
            Text('Get things done. Earn money.',
                style: DaalaTextStyles.caption
                    .copyWith(color: DaalaColors.brandGreen50)),
          ],
        ),
      ),
    );
  }
}
