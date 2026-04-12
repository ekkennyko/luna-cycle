import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

const _accent = AppColors.phaseMenstrual;
const _sheetBg = Color(0xFF1E1118);

class LunaDateRangePicker extends StatefulWidget {
  const LunaDateRangePicker({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.lastDay,
    this.allowOngoing = true,
    this.autoRangeDays,
    required this.onConfirm,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime? lastDay;
  final bool allowOngoing;
  // When set, auto-selects end = start + (autoRangeDays - 1) days on first tap
  final int? autoRangeDays;
  final void Function(DateTime start, DateTime? end) onConfirm;

  @override
  State<LunaDateRangePicker> createState() => _LunaDateRangePickerState();
}

class _LunaDateRangePickerState extends State<LunaDateRangePicker> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late DateTime _focusedDay;

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void initState() {
    super.initState();
    _rangeStart = widget.initialStart;
    _rangeEnd = widget.initialEnd;
    final lastDay = widget.lastDay ?? _today;
    final candidate = widget.initialStart ?? _today;
    _focusedDay = candidate.isAfter(lastDay) ? lastDay : candidate;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    // Tapping already-selected start with no end → reset all
    if (start != null && isSameDay(start, _rangeStart) && end == null && _rangeEnd == null) {
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        _focusedDay = focusedDay;
      });
      return;
    }

    DateTime? effectiveEnd = end;
    if (start != null && end == null && widget.autoRangeDays != null) {
      final auto = start.add(Duration(days: widget.autoRangeDays! - 1));
      final lastDay = widget.lastDay ?? _today;
      effectiveEnd = auto.isAfter(lastDay) ? lastDay : auto;
    }

    setState(() {
      _rangeStart = start;
      _rangeEnd = effectiveEnd;
      _focusedDay = focusedDay;
    });
  }

  String _subtitle(AppLocalizations l10n) {
    if (_rangeStart == null) return l10n.datePickerHintStart;
    if (_rangeEnd == null) return l10n.datePickerHintEnd;
    final days = _rangeEnd!.difference(_rangeStart!).inDays + 1;
    final fmt = DateFormat('MMM d');
    return '${fmt.format(_rangeStart!)} \u2013 ${fmt.format(_rangeEnd!)} (${l10n.datePickerDaysCount(days)})';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveLastDay = widget.lastDay ?? _today;
    final canConfirm = _rangeStart != null;
    final hasOnlyStart = widget.allowOngoing && _rangeStart != null && _rangeEnd == null;
    final subtitle = _subtitle(l10n);

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.datePickerTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                subtitle,
                key: ValueKey(subtitle),
                style: TextStyle(
                  fontSize: 13,
                  color: _rangeEnd != null ? _accent : Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: effectiveLastDay,
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: ''},
              startingDayOfWeek: StartingDayOfWeek.monday,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: _onRangeSelected,
              onPageChanged: (day) => setState(() => _focusedDay = day),
              enabledDayPredicate: (day) => !day.isAfter(effectiveLastDay),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accent),
                ),
                todayTextStyle: const TextStyle(color: Colors.white),
                selectedDecoration: const BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: const BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                ),
                rangeStartTextStyle: const TextStyle(color: Colors.white),
                rangeEndTextStyle: const TextStyle(color: Colors.white),
                rangeHighlightColor: _accent.withValues(alpha: 0.2),
                defaultTextStyle: const TextStyle(color: Colors.white),
                weekendTextStyle: const TextStyle(color: Colors.white),
                disabledTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                outsideTextStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  color: Colors.white,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: _accent),
                rightChevronIcon: const Icon(Icons.chevron_right, color: _accent),
                headerPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: _ConfirmButton(
                enabled: canConfirm,
                label: l10n.datePickerConfirm,
                onTap: canConfirm
                    ? () {
                        Navigator.of(context).pop();
                        widget.onConfirm(_rangeStart!, _rangeEnd);
                      }
                    : null,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: hasOnlyStart
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onConfirm(_rangeStart!, null);
                      },
                      child: Text(
                        l10n.datePickerStillOngoing,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : const SizedBox(height: 12),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.enabled,
    required this.label,
    required this.onTap,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFE05A7A), Color(0xFFC94466)],
                )
              : null,
          color: enabled ? null : Colors.white.withValues(alpha: 0.06),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
