import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final isPremium = isPremiumAsync.when(
      data: (v) => v,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          if (!isPremium)
            _SettingsTile(
              icon: Icons.star_outline,
              title: 'Upgrade to Premium',
              subtitle: 'Analytics, widget, backup and more',
              color: Colors.amber,
              onTap: () => context.push('/paywall'),
            ),
          const _SectionHeader('Privacy'),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'App lock',
            subtitle: 'Biometrics / PIN',
            onTap: () {},
          ),
          const _SectionHeader('Data'),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: 'Create backup',
            subtitle: 'Encrypted .luna file',
            isPremium: !isPremium,
            onTap: isPremium ? () {} : () => context.push('/paywall'),
          ),
          _SettingsTile(
            icon: Icons.restore_outlined,
            title: 'Restore from backup',
            isPremium: !isPremium,
            onTap: isPremium ? () {} : () => context.push('/paywall'),
          ),
          const _SectionHeader('Cycle'),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'Cycle settings',
            subtitle: 'Average length, period length',
            onTap: () {},
          ),
          const _SectionHeader('About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppConstants.appName,
            subtitle: 'Version ${AppConstants.appVersion}',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy policy',
            onTap: () {},
          ),
          if (kDebugMode) ...[
            const _SectionHeader('Debug'),
            _SettingsTile(
              icon: Icons.delete_forever_outlined,
              title: 'Reset profile',
              subtitle: 'Delete all cycle data',
              color: Colors.red,
              onTap: () => _confirmReset(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset profile?'),
        content: const Text('All cycle entries, symptom logs and pregnancies will be deleted. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).resetAllData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ref.read(debugDayOffsetProvider.notifier).reset();
      if (context.mounted) context.go('/onboarding');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.isPremium = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final bool isPremium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: isPremium ? const _PremiumBadge() : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Premium',
        style: TextStyle(
          fontSize: 11,
          color: Colors.amber,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
