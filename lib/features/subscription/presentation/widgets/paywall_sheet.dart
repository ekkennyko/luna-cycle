import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallSheet {
  PaywallSheet._();

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: const _PaywallSheetContent(),
      ),
    );
  }
}

// ── Sheet content ────────────────────────────────────────────────────────────

class _PaywallSheetContent extends ConsumerStatefulWidget {
  const _PaywallSheetContent();

  @override
  ConsumerState<_PaywallSheetContent> createState() => _PaywallSheetContentState();
}

class _PaywallSheetContentState extends ConsumerState<_PaywallSheetContent> {
  String _selected = 'yearly';
  bool _purchased = false;
  bool _loading = false;
  Offerings? _offerings;
  // On non-mobile platforms show fallback prices immediately (no loading spinner).
  bool _offeringsLoaded = !(Platform.isAndroid || Platform.isIOS);

  Color get _accent {
    final phase = ref.watch(currentCyclePhaseProvider).asData?.value;
    return switch (phase) {
      'menstrual' => AppColors.phaseMenstrual,
      'follicular' => AppColors.phaseFolicular,
      'ovulation' => AppColors.phaseOvulation,
      'luteal' => AppColors.phaseLuteal,
      _ => AppColors.phaseMenstrual,
    };
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final o = await Purchases.getOfferings();
      if (mounted)
        setState(() {
          _offerings = o;
          _offeringsLoaded = true;
        });
    } catch (_) {
      if (mounted) setState(() => _offeringsLoaded = true);
    }
  }

  Future<void> _purchase() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      Navigator.of(context).pop();
      return;
    }
    final package = _selected == 'yearly' ? _offerings?.current?.annual : _offerings?.current?.monthly;
    if (package == null) return;

    setState(() => _loading = true);
    try {
      // ignore: deprecated_member_use
      await Purchases.purchasePackage(package);
      ref.invalidate(customerInfoProvider);
      ref.invalidate(isPremiumProvider);
      if (mounted) setState(() => _purchased = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    setState(() => _loading = true);
    try {
      await Purchases.restorePurchases();
      ref.invalidate(customerInfoProvider);
      ref.invalidate(isPremiumProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _yearlyPrice => _offerings?.current?.annual?.storeProduct.priceString ?? '\$19.99';

  String get _yearlyPerMonth {
    final price = _offerings?.current?.annual?.storeProduct.price;
    if (price == null) return '\$1.67';
    return '\$${(price / 12).toStringAsFixed(2)}';
  }

  String get _monthlyPrice => _offerings?.current?.monthly?.storeProduct.priceString ?? '\$2.99';

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final l10n = AppLocalizations.of(context)!;

    if (_purchased) {
      return _SuccessView(accent: accent, l10n: l10n, onContinue: () => Navigator.of(context).pop());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF120A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Scrollable content with ambient glow behind it
          Expanded(
            child: Stack(
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
                          colors: [accent.withValues(alpha: 0.13), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                  child: Column(
                    children: [
                      _Header(accent: accent, l10n: l10n),
                      const SizedBox(height: 20),
                      _TrialBadge(accent: accent, l10n: l10n),
                      const SizedBox(height: 20),
                      _FeaturesList(accent: accent, l10n: l10n),
                      const SizedBox(height: 20),
                      _PricingRow(
                        accent: accent,
                        l10n: l10n,
                        selected: _selected,
                        yearlyPrice: _yearlyPrice,
                        yearlyPerMonth: _yearlyPerMonth,
                        monthlyPrice: _monthlyPrice,
                        offeringsLoaded: _offeringsLoaded,
                        onSelect: (v) => setState(() => _selected = v),
                      ),
                      const SizedBox(height: 8),
                      _FinePrint(
                        l10n: l10n,
                        price: _selected == 'yearly' ? '$_yearlyPrice/year' : '$_monthlyPrice/month',
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed CTA
          _BottomCta(
            accent: accent,
            l10n: l10n,
            loading: _loading,
            onSubscribe: _purchase,
            onRestore: _restore,
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _Header extends StatefulWidget {
  const _Header({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.8, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _opacity,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(color: widget.accent.withValues(alpha: 0.19), blurRadius: 30),
              ],
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 26, color: Colors.white)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.l10n.paywallTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.l10n.paywallSubtitle,
          style: const TextStyle(color: Color(0x72FFFFFF), fontSize: 13),
        ),
      ],
    );
  }
}

class _TrialBadge extends StatelessWidget {
  const _TrialBadge({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.21)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎁', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(
            l10n.paywallTrialBadge,
            style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  const _FeaturesList({required this.accent, required this.l10n});

  final Color accent;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final features = [
      ('📊', l10n.paywallFeatureAnalytics, l10n.paywallFeatureAnalyticsSubtitle),
      ('📱', l10n.paywallFeatureWidget, l10n.paywallFeatureWidgetSubtitle),
      ('🤰', l10n.paywallFeaturePregnancy, l10n.paywallFeaturePregnancySubtitle),
      ('📤', l10n.paywallFeatureExport, l10n.paywallFeatureExportSubtitle),
    ];

    return Column(
      children: [
        for (int i = 0; i < features.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _FeatureCard(
            emoji: features[i].$1,
            title: features[i].$2,
            subtitle: features[i].$3,
            accent: accent,
          ),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '✓',
            style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({
    required this.accent,
    required this.l10n,
    required this.selected,
    required this.yearlyPrice,
    required this.yearlyPerMonth,
    required this.monthlyPrice,
    required this.offeringsLoaded,
    required this.onSelect,
  });

  final Color accent;
  final AppLocalizations l10n;
  final String selected;
  final String yearlyPrice;
  final String yearlyPerMonth;
  final String monthlyPrice;
  final bool offeringsLoaded;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PlanCard(
              accent: accent,
              label: l10n.paywallYearly,
              price: yearlyPrice,
              priceColor: accent,
              priceLabel: '$yearlyPerMonth ${l10n.paywallPerMonth}',
              oldPrice: '\$35.88',
              badge: l10n.paywallBestValue,
              selected: selected == 'yearly',
              loading: !offeringsLoaded,
              onTap: () => onSelect('yearly'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _PlanCard(
              accent: accent,
              label: l10n.paywallMonthly,
              price: monthlyPrice,
              priceColor: const Color(0xCCFFFFFF),
              priceLabel: null,
              oldPrice: null,
              badge: null,
              selected: selected == 'monthly',
              loading: !offeringsLoaded,
              onTap: () => onSelect('monthly'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.accent,
    required this.label,
    required this.price,
    required this.priceColor,
    required this.priceLabel,
    required this.oldPrice,
    required this.badge,
    required this.selected,
    required this.loading,
    required this.onTap,
  });

  final Color accent;
  final String label;
  final String price;
  final Color priceColor;
  final String? priceLabel;
  final String? oldPrice;
  final String? badge;
  final bool selected;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox.expand(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              decoration: BoxDecoration(
                color: selected ? accent.withValues(alpha: 0.09) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? accent : Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (badge == null) const SizedBox(height: 10),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  if (loading)
                    SizedBox(
                      width: 20,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                    )
                  else
                    Text(
                      price,
                      style: TextStyle(color: priceColor, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  const SizedBox(height: 2),
                  if (priceLabel != null)
                    Text(
                      priceLabel!,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10),
                    ),
                  if (oldPrice != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      oldPrice!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.19),
                        fontSize: 9,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white.withValues(alpha: 0.19),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ), // SizedBox.expand
          if (badge != null)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinePrint extends StatelessWidget {
  const _FinePrint({required this.l10n, required this.price});

  final AppLocalizations l10n;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Text(
      l10n.paywallFinePrint(price),
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0x40FFFFFF), fontSize: 11, height: 1.6),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.accent,
    required this.l10n,
    required this.loading,
    required this.onSubscribe,
    required this.onRestore,
  });

  final Color accent;
  final AppLocalizations l10n;
  final bool loading;
  final VoidCallback onSubscribe;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x0AFFFFFF)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: loading ? null : onSubscribe,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 17),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: accent.withValues(alpha: 0.31), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        l10n.paywallCta,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(label: l10n.paywallRestore, onTap: onRestore),
              const _FooterDot(),
              _FooterLink(label: l10n.paywallPrivacyPolicy, onTap: () {}),
              const _FooterDot(),
              _FooterLink(label: l10n.paywallTerms, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(label, style: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 11)),
      ),
    );
  }
}

class _FooterDot extends StatelessWidget {
  const _FooterDot();

  @override
  Widget build(BuildContext context) {
    return const Text('·', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 11));
  }
}

// ── Success screen ───────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.accent, required this.l10n, required this.onContinue});

  final Color accent;
  final AppLocalizations l10n;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF120A0A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.19), blurRadius: 40),
              ],
            ),
            child: const Center(
              child: Text('✦', style: TextStyle(fontSize: 36, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.paywallSuccessTitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.paywallSuccessSubtitle,
            style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 14, height: 1.7),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onContinue,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  l10n.paywallContinue,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
