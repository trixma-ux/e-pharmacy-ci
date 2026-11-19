import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + formats de date en arrière-plan : la première image (splash)
  // s'affiche sans attendre le chargement des SDK Firebase.
  AppBootstrap.start();

  runApp(
    const ProviderScope(
      child: PharmaFlowApp(),
    ),
  );
}

class PharmaFlowApp extends ConsumerWidget {
  const PharmaFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'E-Pharmacy CI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
