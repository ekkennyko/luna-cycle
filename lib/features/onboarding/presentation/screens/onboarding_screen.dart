import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/core/widgets/luna_date_range_picker.dart';
import 'package:luna/shared/widgets/gradient_button.dart';
import 'package:luna/shared/widgets/section_label.dart';

const _accent = AppColors.phaseMenstrual;
const _bg = AppColors.appBackground;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  bool _done = false;
  bool _saving = false;

  DateTime? _periodStart;
  DateTime? _periodEnd;
  DateTime? _prevStart;
  DateTime? _prevEnd;

  int? get _periodLength {
    if (_periodStart == null || _periodEnd == null) return null;
    final diff = _periodEnd!.difference(_periodStart!).inDays;
    return diff >= 0 ? diff + 1 : null;
  }

  int? get _cycleLength {
    if (_prevStart == null || _periodStart == null) return null;
    final diff = _periodStart!.difference(_prevStart!).inDays;
    return diff > 0 ? diff : null;
  }

  bool get _canProceed => _step == 0 ? _periodStart != null : true;

  Future<void> _openDateRangePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LunaDateRangePicker(
        initialStart: _periodStart,
        initialEnd: _periodEnd,
        onConfirm: (start, end) {
          setState(() {
            _periodStart = start;
            _periodEnd = end;
          });
        },
      ),
    );
  }

  Future<void> _openPrevDateRangePicker() async {
    final lastDay = _periodStart?.subtract(const Duration(days: 1));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LunaDateRangePicker(
        initialStart: _prevStart,
        initialEnd: _prevEnd,
        lastDay: lastDay,
        allowOngoing: false,
        autoRangeDays: _periodLength,
        onConfirm: (start, end) {
          setState(() {
            _prevStart = start;
            _prevEnd = end;
          });
        },
      ),
    );
  }

  void _handleNext() {
    if (_step < 1) {
      setState(() => _step++);
    } else {
      _saveAndFinish();
    }
  }

  void _handleBack() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _saveAndFinish() async {
    if (_saving || _periodStart == null) return;
    setState(() => _saving = true);

    try {
      await ref.read(appDatabaseProvider).resetAllData();

      final notifier = ref.read(cycleNotifierProvider.notifier);

      if (_prevStart != null) {
        await notifier.logPeriodStart(_prevStart!, flowIntensity: 2);
        if (_prevEnd != null) {
          await notifier.endPeriod(_prevEnd!);
        }
      }
      await notifier.logPeriodStart(_periodStart!, flowIntensity: 2);

      if (_periodEnd != null) {
        await notifier.endPeriod(_periodEnd!);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PrefsKeys.userCycleLength, _cycleLength ?? 28);
      await prefs.setInt(PrefsKeys.userPeriodLength, _periodLength ?? 5);

      if (!mounted) return;
      setState(() {
        _saving = false;
        _done = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  Future<void> _startFresh() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1118),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        content: Text(
          l10n.onboardingStartFreshDialogBody,
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.onboardingCancel, style: const TextStyle(color: AppColors.darkSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.onboardingStartFresh, style: const TextStyle(color: _accent)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ref.read(appDatabaseProvider).resetAllData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.userCycleLength, 28);
    await prefs.setInt(PrefsKeys.userPeriodLength, 5);
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return _buildCompletionScreen();

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [Color(0x18E05A7A), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoBar(),
                _buildProgressDots(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _step == 0 ? _buildStep0() : _buildStep1(),
                    ),
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBar() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accent.withValues(alpha: 0.25)),
            ),
            child: const Center(child: Text('🌙', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.onboardingAppTitle,
            style: AppTextStyles.titleMedium(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(2, (i) {
          final active = i == _step;
          final past = i < _step;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? _accent
                    : past
                        ? _accent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep0() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingStep0Title,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep0Subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _PeriodRangeField(
            periodStart: _periodStart,
            periodEnd: _periodEnd,
            onTap: _openDateRangePicker,
          ),
          const SizedBox(height: 16),
          // Privacy notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.onboardingPrivacyNotice,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.35),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _startFresh,
              child: Text(
                l10n.onboardingStartFreshLink,
                style: const TextStyle(fontSize: 13, color: Color(0x4DFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final l10n = AppLocalizations.of(context)!;
    final cl = _cycleLength;

    final pl = _periodLength;
    final String periodLenStr;
    if (pl != null) {
      periodLenStr = l10n.onboardingDaysCount(pl);
    } else if (_periodStart != null && _periodEnd == null) {
      periodLenStr = l10n.onboardingStillOngoing;
    } else {
      periodLenStr = '—';
    }

    final String cycleLenStr;
    if (cl != null) {
      cycleLenStr = l10n.onboardingDays(cl);
    } else if (_prevStart != null) {
      cycleLenStr = '...';
    } else {
      cycleLenStr = l10n.onboardingAddDateAbove;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingStep1Title,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingStep1Subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _PeriodRangeField(
            periodStart: _prevStart,
            periodEnd: _prevEnd,
            onTap: _openPrevDateRangePicker,
            allowOngoing: false,
          ),
          if (cl != null) ...[
            const SizedBox(height: 8),
            _HintChip(text: l10n.onboardingDayCycleCalculated(cl)),
          ],
          const SizedBox(height: 16),
          // Preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppRadius.container),
              border: Border.all(color: AppColors.darkCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(
                  text: l10n.onboardingPreview,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                _PreviewRow(
                  label: l10n.onboardingPeriodLength,
                  value: periodLenStr,
                  isPlaceholder: periodLenStr == '—',
                  hasDivider: true,
                ),
                _PreviewRow(
                  label: l10n.onboardingCycleLength,
                  value: cycleLenStr,
                  isPlaceholder: cycleLenStr == '—' || cycleLenStr == l10n.onboardingAddDateAbove,
                  hasDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Did you know card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: _accent.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingDidYouKnow,
                  style: const TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.onboardingDidYouKnowBody,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkSecondaryText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final l10n = AppLocalizations.of(context)!;
    final isLastStep = _step == 1;
    final label = _saving
        ? l10n.onboardingSaving
        : isLastStep
            ? l10n.onboardingGetStarted
            : l10n.onboardingContinue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientButton(
            label: label,
            color: _accent,
            enabled: _canProceed && !_saving,
            onTap: (_canProceed && !_saving) ? _handleNext : null,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: _saving ? null : _handleBack,
                  child: Text(
                    l10n.onboardingBack,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                )
              else
                const SizedBox(),
              if (isLastStep)
                TextButton(
                  onPressed: _saving ? null : _saveAndFinish,
                  child: Text(
                    l10n.onboardingSkip,
                    style: const TextStyle(fontSize: 13, color: AppColors.darkHint),
                  ),
                )
              else
                const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final l10n = AppLocalizations.of(context)!;
    final dateStr = _periodStart != null ? DateFormat('MMM d, y').format(_periodStart!) : '—';

    final String periodLenStr;
    final pl = _periodLength;
    if (pl != null) {
      periodLenStr = l10n.onboardingDays(pl);
    } else if (_periodStart != null && _periodEnd == null) {
      periodLenStr = l10n.onboardingStillOngoing;
    } else {
      periodLenStr = '—';
    }

    final cl = _cycleLength;
    final cycleLenStr = cl != null ? l10n.onboardingDays(cl) : '—';

    final rows = [
      (l10n.onboardingLastPeriodStarted, dateStr),
      (l10n.onboardingPeriodLength, periodLenStr),
      (l10n.onboardingCycleLength, cycleLenStr),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [Color(0x18E05A7A), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: _accent.withValues(alpha: 0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.19),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🌙', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.onboardingAllSet,
                          style: AppTextStyles.displayLarge(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.onboardingCompletionSubtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkSecondaryText,
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        // Summary card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.darkCardBg,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.darkCardBorder),
                          ),
                          child: Column(
                            children: List.generate(rows.length, (i) {
                              final row = rows[i];
                              final isDim = row.$2 == '—';
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          row.$1,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.darkSecondaryText,
                                          ),
                                        ),
                                        Text(
                                          row.$2,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDim ? Colors.white.withValues(alpha: 0.25) : Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < rows.length - 1)
                                    const Divider(
                                      height: 1,
                                      color: AppColors.darkCardBg,
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: GradientButton(
                    label: l10n.onboardingStartTracking,
                    color: _accent,
                    enabled: true,
                    onTap: _completeOnboarding,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.label,
    required this.value,
    required this.isPlaceholder,
    required this.hasDivider,
  });

  final String label;
  final String value;
  final bool isPlaceholder;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder ? Colors.white.withValues(alpha: 0.2) : _accent,
                ),
              ),
            ],
          ),
        ),
        if (hasDivider) const Divider(height: 1, color: AppColors.darkCardBg),
      ],
    );
  }
}

class _PeriodRangeField extends StatelessWidget {
  const _PeriodRangeField({
    required this.periodStart,
    required this.periodEnd,
    required this.onTap,
    this.allowOngoing = true,
  });

  final DateTime? periodStart;
  final DateTime? periodEnd;
  final VoidCallback onTap;
  final bool allowOngoing;

  int? get _days {
    if (periodStart == null || periodEnd == null) return null;
    final diff = periodEnd!.difference(periodStart!).inDays;
    return diff >= 0 ? diff + 1 : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasStart = periodStart != null;
    final hasEnd = periodEnd != null;
    final days = _days;

    final String label;
    final Color labelColor;
    if (!hasStart) {
      label = l10n.onboardingSelectPeriodDates;
      labelColor = Colors.white.withValues(alpha: 0.3);
    } else if (!hasEnd) {
      label = allowOngoing ? '${DateFormat('MMM d').format(periodStart!)} \u2192 ${l10n.onboardingStillOngoing}' : DateFormat('MMM d').format(periodStart!);
      labelColor = _accent;
    } else {
      label = '${DateFormat('MMM d').format(periodStart!)} \u2192 ${DateFormat('MMM d').format(periodEnd!)} (${l10n.onboardingDaysCount(days!)})';
      labelColor = _accent;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppConstants.quickAnim,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasStart ? _accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.container),
              border: Border.all(
                color: hasStart ? _accent.withValues(alpha: 0.31) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                if (!hasStart)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.calendar_today, size: 16, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                ),
                if (hasStart) Icon(Icons.check_circle, size: 18, color: _accent.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.19)),
      ),
      child: Row(
        children: [
          const Text('✦', style: TextStyle(color: _accent, fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(color: _accent, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
