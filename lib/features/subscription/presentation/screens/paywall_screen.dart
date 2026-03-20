import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/constants/strings/paywall_strings.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: offeringsAsync.when(
        data: (offerings) => _PaywallContent(offerings: offerings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.paywallFailed(e.toString()))),
      ),
    );
  }
}

class _PaywallContent extends ConsumerWidget {
  const _PaywallContent({required this.offerings});

  final Offerings offerings;

  static const _features = [
    (Icons.bar_chart, PaywallStrings.advancedAnalytics, PaywallStrings.analyticsSubtitle),
    (Icons.add_circle_outline, PaywallStrings.customSymptoms, PaywallStrings.customSymptomsSubtitle),
    (Icons.child_care_outlined, PaywallStrings.pregnancyTracker, PaywallStrings.pregnancySubtitle),
    (Icons.widgets_outlined, PaywallStrings.homeWidget, PaywallStrings.homeWidgetSubtitle),
    (Icons.backup_outlined, PaywallStrings.encryptedBackup, PaywallStrings.backupSubtitle),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = offerings.current;
    final notifier = ref.read(subscriptionNotifierProvider.notifier);
    final subState = ref.watch(subscriptionNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.paywallLunaPremium,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.paywallSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ..._features.map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(f.$1, color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$2, style: Theme.of(context).textTheme.titleMedium),
                        Text(f.$3, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (current != null) ...[
              _PackageButton(
                label: l10n.paywallYearly,
                sublabel: l10n.paywallSave44,
                package: current.annual,
                onTap: (p) => notifier.purchase(p),
                loading: subState.isLoading,
              ),
              const SizedBox(height: 10),
              _PackageButton(
                label: l10n.paywallMonthly,
                package: current.monthly,
                onTap: (p) => notifier.purchase(p),
                loading: subState.isLoading,
                secondary: true,
              ),
            ],
            TextButton(
              onPressed: () => notifier.restorePurchases(),
              child: Text(l10n.paywallRestorePurchases),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageButton extends StatelessWidget {
  const _PackageButton({
    required this.label,
    this.sublabel,
    required this.package,
    required this.onTap,
    required this.loading,
    this.secondary = false,
  });

  final String label;
  final String? sublabel;
  final Package? package;
  final void Function(Package) onTap;
  final bool loading;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    if (package == null) return const SizedBox.shrink();

    final child = Column(
      children: [
        Text(label),
        if (sublabel != null)
          Text(
            sublabel!,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
      ],
    );

    if (secondary) {
      return OutlinedButton(
        onPressed: loading ? null : () => onTap(package!),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          side: const BorderSide(color: AppColors.primary),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: loading ? null : () => onTap(package!),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : child,
    );
  }
}
