import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';

const _accent = Color(0xFFE05A7A);
const _bg = Color(0xFF120A0A);

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;
  bool _saving = false;

  // Step 0
  DateTime? _lastPeriodDate;

  // Step 1
  double _cycleLength = 28;
  double _periodLength = 5;

  // Step 2
  DateTime? _prevDate1; // period before last
  DateTime? _prevDate2; // two periods ago

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    if (step < 3) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNext() {
    if (_step < 2) {
      _goToStep(_step + 1);
    } else {
      _saveAndFinish();
    }
  }

  void _handleBack() {
    if (_step > 0 && _step < 3) _goToStep(_step - 1);
  }

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
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _accent,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1118),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1118)),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _saveAndFinish() async {
    if (_saving || _lastPeriodDate == null) return;
    setState(() => _saving = true);

    // Save period starts chronologically (oldest first)
    final notifier = ref.read(cycleNotifierProvider.notifier);
    if (_prevDate2 != null) await notifier.logPeriodStart(_prevDate2!, flowIntensity: 2);
    if (_prevDate1 != null) await notifier.logPeriodStart(_prevDate1!, flowIntensity: 2);
    await notifier.logPeriodStart(_lastPeriodDate!, flowIntensity: 2);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_cycle_length', _cycleLength.round());
    await prefs.setInt('user_period_length', _periodLength.round());

    if (!mounted) return;
    setState(() {
      _saving = false;
      _step = 3; // completion screen
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    context.go('/');
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_step == 3) return _buildCompletionScreen();

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
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep0(),
                      _buildStep1(),
                      _buildStep2(),
                    ],
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

  // ── Logo bar ──────────────────────────────────────────────────────────────

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
            'Luna',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress dots ─────────────────────────────────────────────────────────

  Widget _buildProgressDots() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
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

  // ── Step 0: Last period date ───────────────────────────────────────────────

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When did your last\nperiod start?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps Luna calculate where you are in your cycle right now.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _DatePickerField(
            label: 'First day of last period',
            date: _lastPeriodDate,
            onTap: () async {
              final d = await _pickDate(context, initial: _lastPeriodDate);
              if (d != null) setState(() => _lastPeriodDate = d);
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data is stored only on your device. Luna never sends it anywhere.',
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
        ],
      ),
    );
  }

  // ── Step 1: Cycle settings ─────────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your cycle',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These are typical values — you can always adjust them later in Settings.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _LabeledSlider(
            label: 'Average cycle length',
            value: _cycleLength,
            min: 21,
            max: 40,
            unit: 'days',
            onChanged: (v) => setState(() => _cycleLength = v),
          ),
          const SizedBox(height: 24),
          _LabeledSlider(
            label: 'Average period length',
            value: _periodLength,
            min: 2,
            max: 10,
            unit: 'days',
            onChanged: (v) => setState(() => _periodLength = v),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accent.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Did you know?',
                  style: TextStyle(fontSize: 12, color: _accent, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'A typical cycle is 21–35 days. Only 13% of people have exactly 28-day cycles.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
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

  // ── Step 2: Optional historical dates ────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Want more accurate\npredictions?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add start dates of your last 2 periods. Luna will calculate your average cycle length from real data.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          _DatePickerField(
            label: 'Period before last — start date',
            date: _prevDate1,
            optional: true,
            onTap: () async {
              final d = await _pickDate(
                context,
                initial: _prevDate1,
                lastDate: _lastPeriodDate?.subtract(const Duration(days: 1)),
              );
              if (d != null) {
                setState(() {
                  _prevDate1 = d;
                  if (_prevDate2 != null && !_prevDate2!.isBefore(d)) _prevDate2 = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _DatePickerField(
            label: 'Two periods ago — start date',
            date: _prevDate2,
            optional: true,
            onTap: () async {
              final latestAllowed = _prevDate1?.subtract(const Duration(days: 1)) ?? _lastPeriodDate?.subtract(const Duration(days: 20));
              final d = await _pickDate(context, initial: _prevDate2, lastDate: latestAllowed);
              if (d != null) setState(() => _prevDate2 = d);
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'More data = better predictions. You can skip this and add it later.',
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
        ],
      ),
    );
  }

  // ── Shared bottom buttons ─────────────────────────────────────────────────

  Widget _buildBottomButtons() {
    final canProceed = _step == 0 ? _lastPeriodDate != null : true;
    final isLastStep = _step == 2;
    final label = _saving
        ? 'Saving…'
        : isLastStep
            ? 'Get started →'
            : 'Continue →';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GradientButton(
            label: label,
            enabled: canProceed && !_saving,
            onTap: (canProceed && !_saving) ? _handleNext : null,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: _saving ? null : _handleBack,
                  child: Text(
                    '← Back',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
                  ),
                )
              else
                const SizedBox(),
              if (isLastStep)
                TextButton(
                  onPressed: _saving ? null : _saveAndFinish,
                  child: Text(
                    'Skip →',
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.3)),
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

  // ── Completion screen ─────────────────────────────────────────────────────

  Widget _buildCompletionScreen() {
    final extraCycles = (_prevDate1 != null ? 1 : 0) + (_prevDate2 != null ? 1 : 0);
    final dateStr = _lastPeriodDate != null ? DateFormat('MMM d, y').format(_lastPeriodDate!) : '—';
    final rows = [
      ('Last period', dateStr),
      ('Cycle length', '${_cycleLength.round()} days'),
      ('Period length', '${_periodLength.round()} days'),
      ('Extra cycles', extraCycles > 0 ? '$extraCycles added' : '—'),
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
                          "You're all set!",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Luna is ready to track your cycle.\nYour data stays private on your device.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                          ),
                          child: Column(
                            children: List.generate(rows.length, (i) {
                              final row = rows[i];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          row.$1,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(alpha: 0.5),
                                          ),
                                        ),
                                        Text(
                                          row.$2,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < rows.length - 1) Divider(height: 1, color: Colors.white.withValues(alpha: 0.04)),
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
                  child: _GradientButton(
                    label: 'Start tracking →',
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Date picker field with label + optional tag + tappable date input.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.onTap,
    this.optional = false,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
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
                'optional',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.19)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasDate ? _accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasDate ? _accent.withValues(alpha: 0.31) : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? DateFormat('MMMM d, y').format(date!) : 'Tap to select',
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
      ],
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
            ),
            Text(
              '${value.round()} $unit',
              style: const TextStyle(
                fontSize: 16,
                color: _accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _accent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: _accent,
            overlayColor: _accent.withValues(alpha: 0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.round()} $unit',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.15)),
            ),
            Text(
              '${max.round()} $unit',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.15)),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE05A7A), Color(0xCCE05A7A)],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
