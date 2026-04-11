import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/features/subscription/presentation/widgets/paywall_sheet.dart';
import 'package:luna/l10n/app_localizations.dart';

Color _cyclePhaseColor(CyclePhase phase) => switch (phase) {
      CyclePhase.menstrual => AppColors.phaseMenstrual,
      CyclePhase.follicular => AppColors.phaseFolicular,
      CyclePhase.ovulation => AppColors.phaseOvulation,
      CyclePhase.luteal => AppColors.phaseLuteal,
    };

String _phaseName(CyclePhase phase, AppLocalizations l10n) => switch (phase) {
      CyclePhase.menstrual => l10n.homePhaseMenstrual,
      CyclePhase.follicular => l10n.homePhaseFollicular,
      CyclePhase.ovulation => l10n.homePhaseOvulation,
      CyclePhase.luteal => l10n.homePhaseLuteal,
    };

const _moodEmojis = ['😔', '😐', '🙂', '😊', '🤩'];
String _moodEmoji(double avg) => _moodEmojis[(avg.round() - 1).clamp(0, 4)];

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider).asData?.value ?? false;
    final accent = _cyclePhaseColor(ref.watch(currentCyclePhaseProvider).asData?.value ?? CyclePhase.menstrual);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [accent.withValues(alpha: 0.09), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        l10n.analyticsTitle,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.analyticsSubtitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: accent,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionHeader(title: l10n.analyticsOverview),
                      const SizedBox(height: 14),
                      _OverviewSection(accent: accent, l10n: l10n),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.analyticsCycleLength,
                        isPremium: true,
                        isLocked: !isPremium,
                        accent: accent,
                        onUnlock: () => PaywallSheet.show(context),
                      ),
                      const SizedBox(height: 14),
                      if (isPremium)
                        _CycleLengthChart(accent: accent, l10n: l10n)
                      else
                        _PremiumBlur(accent: accent, onUnlock: () => PaywallSheet.show(context), l10n: l10n),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.analyticsPeriodLength,
                        isPremium: true,
                        isLocked: !isPremium,
                        accent: accent,
                        onUnlock: () => PaywallSheet.show(context),
                      ),
                      const SizedBox(height: 14),
                      if (isPremium) _PeriodLengthChart(l10n: l10n) else _PremiumBlur(accent: accent, onUnlock: () => PaywallSheet.show(context), l10n: l10n),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.analyticsMoodByPhase,
                        isPremium: true,
                        isLocked: !isPremium,
                        accent: accent,
                        onUnlock: () => PaywallSheet.show(context),
                      ),
                      const SizedBox(height: 14),
                      _MoodByPhaseSection(isPremium: isPremium, accent: accent, l10n: l10n),
                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.analyticsTopSymptoms),
                      const SizedBox(height: 14),
                      _TopSymptomsSection(l10n: l10n),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: l10n.analyticsHealthInsights,
                        isPremium: true,
                        isLocked: !isPremium,
                        accent: accent,
                        onUnlock: () => PaywallSheet.show(context),
                      ),
                      const SizedBox(height: 14),
                      if (isPremium)
                        _HealthInsightsSection(accent: accent, l10n: l10n)
                      else
                        _PremiumBlur(accent: accent, onUnlock: () => PaywallSheet.show(context), l10n: l10n),
                    ]),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.isPremium = false,
    this.isLocked = false,
    this.accent,
    this.onUnlock,
  });

  final String title;
  final bool isPremium;
  final bool isLocked;
  final Color? accent;
  final VoidCallback? onUnlock;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0x66FFFFFF),
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isPremium && isLocked && accent != null && onUnlock != null)
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: accent!.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent!.withValues(alpha: 0.25)),
              ),
              child: Text(
                '✦ PREMIUM',
                style: TextStyle(
                  fontSize: 10,
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.sub, required this.color});

  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Color(0x66FFFFFF), letterSpacing: 0.5),
            textAlign: TextAlign.center,
          ),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(
              sub!,
              style: const TextStyle(fontSize: 10, color: Color(0x40FFFFFF)),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget({
    required this.data,
    required this.color,
    required this.unit,
    this.maxVal,
  });

  final List<int> data;
  final Color color;
  final String unit;
  final int? maxVal;

  @override
  Widget build(BuildContext context) {
    final max = (maxVal ?? (data.reduce((a, b) => a > b ? a : b) + 2)).toDouble();

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < data.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${data[i]}$unit',
                    style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: (data[i] / max) * 60,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      gradient: i == data.length - 1
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color, color.withValues(alpha: 0.53)],
                            )
                          : null,
                      color: i != data.length - 1 ? color.withValues(alpha: 0.25) : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PremiumBlur extends StatelessWidget {
  const _PremiumBlur({required this.accent, required this.onUnlock, required this.l10n});

  final Color accent;
  final VoidCallback onUnlock;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF120A0A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✦', style: TextStyle(fontSize: 20, color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            l10n.analyticsPremiumFeature,
            style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.analyticsUnlock,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Text(message, style: const TextStyle(fontSize: 13, color: Color(0x4DFFFFFF))),
    );
  }
}

class _OverviewSection extends ConsumerWidget {
  const _OverviewSection({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avgCycle = ref.watch(averageCycleLengthProvider).asData?.value;
    final avgPeriod = ref.watch(averagePeriodLengthProvider).asData?.value;
    final cycleLengths = ref.watch(cycleLengthsProvider).asData?.value ?? [];
    final periodLengths = ref.watch(completedPeriodLengthsProvider).asData?.value ?? [];

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: l10n.analyticsAvgCycle,
            value: avgCycle != null ? '${avgCycle}d' : '--',
            sub: cycleLengths.isEmpty ? null : l10n.analyticsLastNCycles(cycleLengths.length),
            color: accent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.analyticsAvgPeriod,
            value: avgPeriod != null ? '${avgPeriod}d' : '--',
            sub: periodLengths.isEmpty ? null : l10n.analyticsLastNPeriods(periodLengths.length),
            color: AppColors.phaseFolicular,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: l10n.analyticsTracked,
            value: '${cycleLengths.length}',
            sub: l10n.analyticsCyclesTotal,
            color: AppColors.phaseOvulation,
          ),
        ),
      ],
    );
  }
}

class _CycleLengthChart extends ConsumerWidget {
  const _CycleLengthChart({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(cycleLengthHistoryProvider).asData?.value ?? [];
    if (data.isEmpty) return _EmptyCard(message: l10n.analyticsNoData);
    return _ChartCard(
      l10n: l10n,
      count: data.length,
      child: _BarChartWidget(data: data, color: accent, unit: 'd'),
    );
  }
}

class _PeriodLengthChart extends ConsumerWidget {
  const _PeriodLengthChart({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(periodLengthHistoryProvider).asData?.value ?? [];
    if (data.isEmpty) return _EmptyCard(message: l10n.analyticsNoData);
    return _ChartCard(
      l10n: l10n,
      count: data.length,
      child: _BarChartWidget(data: data, color: AppColors.phaseFolicular, unit: 'd', maxVal: 10),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.l10n, required this.count, required this.child});

  final AppLocalizations l10n;
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          child,
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$count ${l10n.analyticsCyclesAgo}', style: const TextStyle(fontSize: 10, color: Color(0x33FFFFFF))),
              Text(l10n.analyticsLatest, style: const TextStyle(fontSize: 10, color: Color(0x33FFFFFF))),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodByPhaseSection extends ConsumerWidget {
  const _MoodByPhaseSection({
    required this.isPremium,
    required this.accent,
    required this.l10n,
  });

  final bool isPremium;
  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodMap = ref.watch(moodByPhaseProvider).asData?.value ?? {};
    const phases = CyclePhase.values;

    if (isPremium) {
      if (moodMap.isEmpty) return _EmptyCard(message: l10n.analyticsNoData);
      final peakPhase = moodMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            for (int i = 0; i < phases.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _MoodPhaseRow(phase: phases[i], avg: moodMap[phases[i]] ?? 0.0, l10n: l10n),
            ],
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.15)),
              ),
              child: Text(
                '✦ ${l10n.analyticsMoodPeak(_phaseName(peakPhase, l10n))}',
                style: const TextStyle(fontSize: 12, color: Color(0x80FFFFFF), height: 1.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              for (int i = 0; i < phases.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: i < phases.length - 1 ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04))) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _phaseName(phases[i], l10n),
                        style: TextStyle(fontSize: 13, color: _cyclePhaseColor(phases[i])),
                      ),
                      Text(
                        moodMap.containsKey(phases[i]) ? _moodEmoji(moodMap[phases[i]]!) : '—',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.analyticsUpgradeCharts,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Color(0x33FFFFFF)),
        ),
      ],
    );
  }
}

class _MoodPhaseRow extends StatelessWidget {
  const _MoodPhaseRow({required this.phase, required this.avg, required this.l10n});

  final CyclePhase phase;
  final double avg;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = _cyclePhaseColor(phase);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            _phaseName(phase, l10n),
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  if (avg > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: constraints.maxWidth * (avg / 5.0).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withValues(alpha: 0.6), color],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          avg > 0 ? _moodEmoji(avg) : '—',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

class _TopSymptomsSection extends ConsumerWidget {
  const _TopSymptomsSection({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptoms = ref.watch(topSymptomsProvider).asData?.value ?? [];
    if (symptoms.isEmpty) return _EmptyCard(message: l10n.analyticsNoData);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < symptoms.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i < symptoms.length - 1 ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.04))) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _cyclePhaseColor(symptoms[i].phase).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _cyclePhaseColor(symptoms[i].phase),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symptoms[i].name,
                          style: const TextStyle(fontSize: 13, color: Color(0xCCFFFFFF)),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _phaseName(symptoms[i].phase, l10n),
                          style: TextStyle(
                            fontSize: 10,
                            color: _cyclePhaseColor(symptoms[i].phase),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${symptoms[i].count}×',
                      style: const TextStyle(fontSize: 11, color: Color(0x4DFFFFFF)),
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

class _HealthInsightsSection extends ConsumerWidget {
  const _HealthInsightsSection({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warnings = ref.watch(healthWarningsProvider).asData?.value ?? [];

    if (warnings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            const Text('✓', style: TextStyle(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              l10n.analyticsAllNormal,
              style: const TextStyle(fontSize: 13, color: Color(0x66FFFFFF)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < warnings.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x0FFFB400),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33FFB400)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _warningText(warnings[i]),
                    style: const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _warningText(HealthWarning w) => switch (w.type) {
        WarningType.longCycle => l10n.analyticsWarningLongCycle(w.days),
        WarningType.shortCycle => l10n.analyticsWarningShortCycle(w.days),
        WarningType.longPeriod => l10n.analyticsWarningLongPeriod(w.days),
        WarningType.irregularity => l10n.analyticsWarningIrregular,
      };
}
