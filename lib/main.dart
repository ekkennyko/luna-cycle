import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/notifications/notification_service.dart';
import 'package:luna/core/router/app_router.dart';
import 'package:luna/core/theme/app_theme.dart';
import 'package:luna/features/settings/presentation/widgets/lock_screen.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationService.init();
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
  if (Platform.isAndroid || Platform.isIOS) {
    await initRevenueCat();
  }

  final appLockEnabled = prefs.getBool(PrefsKeys.appLockEnabled) ?? false;
  final showLock = appLockEnabled && onboardingDone && (Platform.isAndroid || Platform.isIOS);

  runApp(
    ProviderScope(
      child: LunaApp(showOnboarding: !onboardingDone, showLock: showLock),
    ),
  );

  if (onboardingDone && (Platform.isAndroid || Platform.isIOS)) {
    unawaited(_scheduleStartupNotifications(prefs));
  }
}

Future<void> _scheduleStartupNotifications(SharedPreferences prefs) async {
  final container = ProviderContainer();
  try {
    final nextPeriod = await container.read(nextPeriodDateProvider.future);
    final phase = await container.read(currentPhaseProvider.future);
    final status = await container.read(periodStatusProvider.future);
    if (nextPeriod == null || phase == null) return;

    await NotificationService.rescheduleAll(
      nextPeriodDate: nextPeriod,
      fertileWindowStart: phase.fertileWindow.start,
      periodReminderEnabled: prefs.getBool(PrefsKeys.notificationsPeriodEnabled) ?? true,
      periodReminderDays: prefs.getInt(PrefsKeys.notificationsPeriodDays) ?? 2,
      fertileWindowEnabled: prefs.getBool(PrefsKeys.notificationsFertileEnabled) ?? true,
      latePeriodEnabled: prefs.getBool(PrefsKeys.notificationsLateEnabled) ?? true,
      daysLate: status.$1 == PeriodStatus.late ? status.$2 : 0,
      appLockEnabled: prefs.getBool(PrefsKeys.appLockEnabled) ?? false,
    );
  } catch (_) {
    // Startup notification scheduling is best-effort
  } finally {
    container.dispose();
  }
}

class LunaApp extends ConsumerStatefulWidget {
  const LunaApp({
    super.key,
    required this.showOnboarding,
    this.showLock = false,
  });

  final bool showOnboarding;
  final bool showLock;

  @override
  ConsumerState<LunaApp> createState() => _LunaAppState();
}

class _LunaAppState extends ConsumerState<LunaApp> {
  late bool _locked;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _locked = widget.showLock;
    _router = createRouter(widget.showOnboarding ? '/onboarding' : '/');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(encryptionServiceProvider, (_, service) async {
      if (!service.isInitialized) await service.init();
    });

    if (_locked) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LockScreen(onUnlocked: () => setState(() => _locked = false)),
      );
    }

    return MaterialApp.router(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
