import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/router/app_router.dart';
import 'package:luna/core/theme/app_theme.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initRevenueCat();
  runApp(const ProviderScope(child: LunaApp()));
}

class LunaApp extends ConsumerWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(encryptionServiceProvider, (_, service) async {
      if (!service.isInitialized) await service.init();
    });

    return MaterialApp.router(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
