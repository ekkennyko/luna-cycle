import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/core/notifications/notification_service.dart';
import 'package:luna/features/settings/presentation/screens/set_pin_screen.dart';
import 'package:luna/features/settings/presentation/widgets/lock_screen.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/features/subscription/presentation/widgets/paywall_sheet.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final isPremium = isPremiumAsync.when(
      data: (v) => v,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          if (!isPremium)
            _SettingsTile(
              icon: Icons.star_outline,
              title: l10n.settingsUpgradeToPremium,
              subtitle: l10n.settingsUpgradeSubtitle,
              color: Colors.amber,
              onTap: () => PaywallSheet.show(context),
            ),
          const _AppLockSection(),
          _SectionHeader(l10n.settingsNotifications),
          const _NotificationsSection(),
          _SectionHeader(l10n.settingsData),
          _SettingsTile(
            icon: Icons.backup_outlined,
            title: l10n.settingsCreateBackup,
            subtitle: l10n.settingsEncryptedFile,
            isPremium: !isPremium,
            onTap: isPremium ? () {} : () => PaywallSheet.show(context),
          ),
          _SettingsTile(
            icon: Icons.restore_outlined,
            title: l10n.settingsRestoreFromBackup,
            isPremium: !isPremium,
            onTap: isPremium ? () {} : () => PaywallSheet.show(context),
          ),
          _SectionHeader(l10n.settingsCycle),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: l10n.settingsCycleSettings,
            subtitle: l10n.settingsCycleLengthSubtitle,
            onTap: () {},
          ),
          _SectionHeader(l10n.settingsAbout),
          _SettingsTile(
            icon: Icons.info_outline,
            title: AppConstants.appName,
            subtitle: l10n.settingsVersion(AppConstants.appVersion),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.settingsPrivacyPolicy,
            onTap: () => launchUrl(
              Uri.parse(AppConstants.privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          if (kDebugMode) ...[
            _SectionHeader(l10n.settingsDebug),
            _SettingsTile(
              icon: Icons.delete_forever_outlined,
              title: l10n.settingsResetProfile,
              subtitle: l10n.settingsDeleteAllData,
              color: Colors.red,
              onTap: () => _confirmReset(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsResetProfileQuestion),
        content: Text(l10n.settingsResetDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.settingsReset),
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

class _NotificationsSection extends ConsumerStatefulWidget {
  const _NotificationsSection();

  @override
  ConsumerState<_NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends ConsumerState<_NotificationsSection> {
  bool _periodEnabled = true;
  int _periodDays = 2;
  bool _fertileEnabled = true;
  bool _lateEnabled = true;
  bool _loaded = false;

  static const _dayOptions = [1, 2, 3, 5, 7];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _periodEnabled = prefs.getBool(PrefsKeys.notificationsPeriodEnabled) ?? true;
      _periodDays = prefs.getInt(PrefsKeys.notificationsPeriodDays) ?? 2;
      _fertileEnabled = prefs.getBool(PrefsKeys.notificationsFertileEnabled) ?? true;
      _lateEnabled = prefs.getBool(PrefsKeys.notificationsLateEnabled) ?? true;
      _loaded = true;
    });
  }

  Future<void> _saveAndReschedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.notificationsPeriodEnabled, _periodEnabled);
    await prefs.setInt(PrefsKeys.notificationsPeriodDays, _periodDays);
    await prefs.setBool(PrefsKeys.notificationsFertileEnabled, _fertileEnabled);
    await prefs.setBool(PrefsKeys.notificationsLateEnabled, _lateEnabled);

    final nextPeriod = await ref.read(nextPeriodDateProvider.future);
    final phase = await ref.read(currentPhaseProvider.future);
    final status = await ref.read(periodStatusProvider.future);
    if (nextPeriod == null || phase == null) return;

    await NotificationService.rescheduleAll(
      nextPeriodDate: nextPeriod,
      fertileWindowStart: phase.fertileWindow.start,
      periodReminderEnabled: _periodEnabled,
      periodReminderDays: _periodDays,
      fertileWindowEnabled: _fertileEnabled,
      latePeriodEnabled: _lateEnabled,
      daysLate: status.$1 == PeriodStatus.late ? status.$2 : 0,
      appLockEnabled: prefs.getBool(PrefsKeys.appLockEnabled) ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ToggleTile(
          icon: Icons.notifications_outlined,
          title: l10n.settingsPeriodReminder,
          subtitle: l10n.settingsPeriodReminderSubtitle,
          value: _periodEnabled,
          onChanged: (v) {
            setState(() => _periodEnabled = v);
            _saveAndReschedule();
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _periodEnabled
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    children: _dayOptions
                        .map(
                          (d) => ChoiceChip(
                            label: Text(l10n.settingsReminderDays(d)),
                            selected: _periodDays == d,
                            onSelected: (v) {
                              if (v) {
                                setState(() => _periodDays = d);
                                _saveAndReschedule();
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        _ToggleTile(
          icon: Icons.favorite_outline,
          title: l10n.settingsFertileWindow,
          subtitle: l10n.settingsFertileWindowSubtitle,
          value: _fertileEnabled,
          onChanged: (v) {
            setState(() => _fertileEnabled = v);
            _saveAndReschedule();
          },
        ),
        _ToggleTile(
          icon: Icons.schedule_outlined,
          title: l10n.settingsLatePeriod,
          subtitle: l10n.settingsLatePeriodSubtitle,
          value: _lateEnabled,
          onChanged: (v) {
            setState(() => _lateEnabled = v);
            _saveAndReschedule();
          },
        ),
      ],
    );
  }
}

class _AppLockSection extends ConsumerStatefulWidget {
  const _AppLockSection();

  @override
  ConsumerState<_AppLockSection> createState() => _AppLockSectionState();
}

class _AppLockSectionState extends ConsumerState<_AppLockSection> {
  bool _enabled = false;
  bool _loaded = false;

  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool(PrefsKeys.appLockEnabled) ?? false;
      _loaded = true;
    });
  }

  Future<void> _onToggle(bool value) async {
    if (value) {
      final nav = Navigator.of(context, rootNavigator: true);
      final result = await nav.push<bool>(
        MaterialPageRoute(builder: (_) => const SetPinScreen()),
      );
      if (result == true && mounted) setState(() => _enabled = true);
    } else {
      final verified = await LockScreen.verify(context);
      if (!verified || !mounted) return;
      await _storage.delete(key: PrefsKeys.appLockPinHash);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsKeys.appLockEnabled, false);
      if (mounted) setState(() => _enabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || !_loaded) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(l10n.settingsPrivacy),
        _ToggleTile(
          icon: Icons.lock_outline,
          title: l10n.settingsAppLock,
          subtitle: l10n.settingsBiometricsPin,
          value: _enabled,
          onChanged: (v) => _onToggle(v),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
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
      child: Text(
        AppLocalizations.of(context)!.settingsPremium,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.amber,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
