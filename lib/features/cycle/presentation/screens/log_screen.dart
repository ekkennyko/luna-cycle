import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  bool _isPeriod = false;
  int _flowIntensity = 2;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMMM d, yyyy').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(formatted),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionCard(
              title: 'Period',
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('First day / ongoing'),
                    value: _isPeriod,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isPeriod = v),
                  ),
                  if (_isPeriod) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flow intensity',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          _FlowIntensitySelector(
                            value: _flowIntensity,
                            onChanged: (v) => setState(() => _flowIntensity = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isPeriod) {
      await ref.read(cycleNotifierProvider.notifier).logPeriodStart(widget.date);
    }
    if (mounted) context.pop();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          child,
        ],
      ),
    );
  }
}

class _FlowIntensitySelector extends StatelessWidget {
  const _FlowIntensitySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = [
    '',
    'Spotting',
    'Light',
    'Heavy',
    'Very\nheavy',
  ];
  static const _icons = [
    null,
    Icons.water_drop_outlined,
    Icons.water_drop,
    Icons.opacity,
    Icons.waves,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) {
        final v = i + 1;
        final selected = v == value;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _icons[v],
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[v],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
