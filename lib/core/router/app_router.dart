import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/cycle/presentation/screens/home_screen.dart';
import 'package:luna/features/cycle/presentation/screens/log_screen.dart';
import 'package:luna/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:luna/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:luna/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:luna/features/settings/presentation/screens/settings_screen.dart';
import 'package:luna/features/subscription/presentation/screens/paywall_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(String initialLocation) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/onboarding',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => _MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: '/calendar',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CalendarScreen(),
              ),
            ),
            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AnalyticsScreen(),
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/log',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final dateStr = state.uri.queryParameters['date'];
            final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
            return LogScreen(date: date);
          },
        ),
        GoRoute(
          path: '/paywall',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PaywallScreen(),
        ),
      ],
    );

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});

  final Widget child;

  static Color _phaseColor(String? phase) => switch (phase) {
        'menstrual' => AppColors.phaseMenstrual,
        'follicular' => AppColors.phaseFolicular,
        'ovulation' => AppColors.phaseOvulation,
        'luteal' => AppColors.phaseLuteal,
        _ => AppColors.phaseMenstrual,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final phaseColor = _phaseColor(ref.watch(currentCyclePhaseProvider).asData?.value);

    int selectedIndex = 0;
    if (location.startsWith('/calendar')) selectedIndex = 1;
    if (location.startsWith('/analytics')) selectedIndex = 2;
    if (location.startsWith('/settings')) selectedIndex = 3;

    const navItems = [
      (icon: '◯', label: 'Cycle', route: '/'),
      (icon: '▦', label: 'Calendar', route: '/calendar'),
      (icon: '⌇', label: 'Analytics', route: '/analytics'),
      (icon: '⊹', label: 'Settings', route: '/settings'),
    ];

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBarBg,
          border: Border(top: BorderSide(color: AppColors.navBarBorder)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (i) {
                final item = navItems[i];
                final selected = selectedIndex == i;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(item.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? phaseColor.withValues(alpha: 0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.icon,
                          style: TextStyle(
                            fontSize: 18,
                            color: selected ? phaseColor : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? phaseColor : Colors.white.withValues(alpha: 0.3),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
