import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/router/app_router.dart';
import 'package:luna/core/theme/app_theme.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
  if (Platform.isAndroid || Platform.isIOS) {
    await initRevenueCat();
  }
  runApp(ProviderScope(child: LunaApp(showOnboarding: !onboardingDone)));
}

class LunaApp extends ConsumerWidget {
  const LunaApp({super.key, required this.showOnboarding});

  final bool showOnboarding;

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
      routerConfig: createRouter(showOnboarding ? '/onboarding' : '/'),
    );
  }
}
