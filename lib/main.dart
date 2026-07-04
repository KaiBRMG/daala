import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/theme.dart';

/// Phase 1 bootstrap: ProviderScope + GoRouter. No Firebase init — the
/// firebase_* dependencies are reserved for later phases and must not be
/// imported or called anywhere in Phase 1.
void main() {
  runApp(const ProviderScope(child: DaalaApp()));
}

class DaalaApp extends ConsumerWidget {
  const DaalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Daala',
      debugShowCheckedModeBanner: false,
      theme: buildDaalaTheme(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
