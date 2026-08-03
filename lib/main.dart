import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // TODO(phase2-setup): activate App Check here once Play Integrity and
  // DeviceCheck are registered in the Firebase console. Enforcing App Check on
  // Auth is the primary defence against SMS toll fraud — see CLAUDE.md.
  runApp(const ProviderScope(child: DaalaApp()));
}

class DaalaApp extends ConsumerWidget {
  const DaalaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Daala',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
