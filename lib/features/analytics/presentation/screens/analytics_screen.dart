import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: isPremiumAsync.when(
        data: (isPremium) {
          if (!isPremium) {
            return _PremiumGate(onUpgrade: () => context.push('/paywall'));
          }
          return const _AnalyticsContent();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _AnalyticsContent(), // show content on error to avoid blocking the screen
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Analytics — Premium',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cycle charts, phase symptoms and predictions are available with a Premium subscription.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onUpgrade,
              child: const Text('Try Premium'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Cycle charts — coming soon'));
  }
}
