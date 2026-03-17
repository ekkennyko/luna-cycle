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
import 'package:luna/core/constants/strings/onboarding_strings.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/core/theme/date_picker_theme.dart';
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
  bool _periodOngoing = false;

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

  int? get _prevPeriodLength {
    if (_prevStart == null || _prevEnd == null) return null;
    final diff = _prevEnd!.difference(_prevStart!).inDays;
    return diff >= 0 ? diff + 1 : null;
  }

  bool get _canProceed => _step == 0 ? _periodStart != null : true;

  Future<DateTime?> _pickDate(
    BuildContext context, {
    DateTime? initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now.subtract(const Duration(days: 1)),
      firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 2)),
      lastDate: lastDate ?? now,
      builder: (ctx, child) => Theme(
        data: appDatePickerTheme(_accent),
        child: child!,
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
  }

  Future<void> _startFresh() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1118),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        content: const Text(
          OnboardingStrings.startFreshDialogBody,
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(OnboardingStrings.cancel, style: TextStyle(color: AppColors.darkSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(OnboardingStrings.startFresh, style: TextStyle(color: _accent)),
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
            OnboardingStrings.appTitle,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OnboardingStrings.step0Title,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            OnboardingStrings.step0Subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _DatePickerField(
            label: OnboardingStrings.whenDidItStart,
            date: _periodStart,
            onTap: () async {
              final d = await _pickDate(context, initial: _periodStart);
              if (d != null) {
                setState(() {
                  _periodStart = d;
                  // Clear end if it's no longer valid
                  if (_periodEnd != null && !_periodEnd!.isAfter(d)) {
                    _periodEnd = null;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 16),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            child: _periodOngoing
                ? const SizedBox.shrink()
                : _DatePickerField(
                    label: OnboardingStrings.whenDidItEnd,
                    date: _periodEnd,
                    optional: true,
                    hint: _periodLength != null ? '$_periodLength day period — got it!' : null,
                    onTap: () async {
                      if (_periodStart == null) return;
                      final d = await _pickDate(
                        context,
                        initial: _periodEnd,
                        firstDate: _periodStart!,
                      );
                      if (d != null) {
                        setState(() {
                          _periodEnd = d;
                          _periodOngoing = false;
                        });
                      }
                    },
                  ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _periodEnd == null
                ? AnimatedOpacity(
                    opacity: 1.0,
                    duration: AppConstants.quickAnim,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _periodOngoing = !_periodOngoing;
                        if (_periodOngoing) _periodEnd = null;
                      }),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Switch(
                            value: _periodOngoing,
                            onChanged: (v) => setState(() {
                              _periodOngoing = v;
                              if (v) _periodEnd = null;
                            }),
                            activeThumbColor: _accent,
                            activeTrackColor: _accent.withValues(alpha: 0.28),
                            inactiveThumbColor: Colors.white.withValues(alpha: 0.35),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            OnboardingStrings.stillOngoing,
                            style: TextStyle(
                              fontSize: 14,
                              color: _periodOngoing ? Colors.white : Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
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
                    OnboardingStrings.privacyNotice,
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
              child: const Text(
                OnboardingStrings.startFreshLink,
                style: TextStyle(fontSize: 13, color: Color(0x4DFFFFFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final prevPl = _prevPeriodLength;
    final cl = _cycleLength;

    final String periodLenStr;
    if (prevPl != null) {
      periodLenStr = '$prevPl days';
    } else if (_prevStart != null && _prevEnd == null) {
      periodLenStr = '—';
    } else {
      periodLenStr = '—';
    }

    final String cycleLenStr;
    if (cl != null) {
      cycleLenStr = '$cl days';
    } else if (_prevStart != null) {
      cycleLenStr = '...';
    } else {
      cycleLenStr = OnboardingStrings.addDateAbove;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            OnboardingStrings.step1Title,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            OnboardingStrings.step1Subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _DatePickerField(
            label: OnboardingStrings.prevPeriodStart,
            date: _prevStart,
            optional: true,
            hint: cl != null ? '$cl day cycle — calculated from your data ✓' : null,
            onTap: () async {
              final last = _periodStart?.subtract(const Duration(days: 1));
              final d = await _pickDate(
                context,
                initial: _prevStart ?? last,
                lastDate: last,
              );
              if (d != null) {
                setState(() {
                  _prevStart = d;
                  if (_prevEnd != null && !_prevEnd!.isAfter(d)) {
                    _prevEnd = null;
                  }
                });
              }
            },
          ),
          if (_prevStart != null) ...[
            const SizedBox(height: 16),
            _DatePickerField(
              label: OnboardingStrings.prevPeriodEnd,
              date: _prevEnd,
              optional: true,
              hint: prevPl != null ? '$prevPl day period — got it!' : null,
              onTap: () async {
                final maxDate = _periodStart?.subtract(const Duration(days: 1));
                final d = await _pickDate(
                  context,
                  initial: _prevEnd ?? _prevStart!,
                  firstDate: _prevStart!,
                  lastDate: maxDate,
                );
                if (d != null) setState(() => _prevEnd = d);
              },
            ),
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
                  text: OnboardingStrings.preview,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                _PreviewRow(
                  label: OnboardingStrings.periodLength,
                  value: periodLenStr,
                  isPlaceholder: periodLenStr == '—',
                  hasDivider: true,
                ),
                _PreviewRow(
                  label: OnboardingStrings.cycleLength,
                  value: cycleLenStr,
                  isPlaceholder: cycleLenStr == '—' || cycleLenStr == OnboardingStrings.addDateAbove,
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OnboardingStrings.didYouKnow,
                  style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  OnboardingStrings.didYouKnowBody,
                  style: TextStyle(
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
    final isLastStep = _step == 1;
    final label = _saving
        ? OnboardingStrings.saving
        : isLastStep
            ? OnboardingStrings.getStarted
            : OnboardingStrings.continueButton;

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
                    OnboardingStrings.back,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                )
              else
                const SizedBox(),
              if (isLastStep)
                TextButton(
                  onPressed: _saving ? null : _saveAndFinish,
                  child: const Text(
                    OnboardingStrings.skip,
                    style: TextStyle(fontSize: 13, color: AppColors.darkHint),
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
    final dateStr = _periodStart != null ? DateFormat('MMM d, y').format(_periodStart!) : '—';

    final String periodLenStr;
    final pl = _periodLength;
    if (pl != null) {
      periodLenStr = '$pl days';
    } else if (_periodStart != null && _periodEnd == null) {
      periodLenStr = OnboardingStrings.stillOngoing;
    } else {
      periodLenStr = '—';
    }

    final cl = _cycleLength;
    final cycleLenStr = cl != null ? '$cl days' : '—';

    final rows = [
      (OnboardingStrings.lastPeriodStarted, dateStr),
      (OnboardingStrings.periodLength, periodLenStr),
      (OnboardingStrings.cycleLength, cycleLenStr),
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
                          OnboardingStrings.allSet,
                          style: AppTextStyles.displayLarge(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          OnboardingStrings.completionSubtitle,
                          style: TextStyle(
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
                    label: OnboardingStrings.startTracking,
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.optional = false,
    this.hint,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool optional;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final showHint = hasDate && hint != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.44)),
            ),
            if (optional)
              Text(
                OnboardingStrings.optional,
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.19)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppConstants.quickAnim,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasDate ? _accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.container),
              border: Border.all(
                color: hasDate ? _accent.withValues(alpha: 0.31) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? DateFormat('MMMM d, y').format(date!) : OnboardingStrings.tapToSelect,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasDate ? Colors.white : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                if (hasDate) Icon(Icons.check_circle, size: 18, color: _accent.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: showHint
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
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
                          child: Text(
                            hint!,
                            style: const TextStyle(color: _accent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
