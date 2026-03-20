import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/features/settings/presentation/widgets/pin_pad.dart';
import 'package:luna/l10n/app_localizations.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  static Future<bool> verify(BuildContext context) async {
    final nav = Navigator.of(context, rootNavigator: true);
    return await nav.push<bool>(
          MaterialPageRoute(
            builder: (ctx) => LockScreen(
              onUnlocked: () => Navigator.of(ctx, rootNavigator: true).pop(true),
            ),
          ),
        ) ??
        false;
  }

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  int _attempts = 0;
  bool _lockedOut = false;
  int _lockoutSeconds = 30;
  Timer? _lockoutTimer;
  bool _verifying = false;
  bool _hasBiometrics = false;

  late final AnimationController _shakeCtrl;
  late final Animation<Offset> _shakeAnim;

  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.05, 0),
          end: const Offset(-0.05, 0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-0.05, 0),
          end: const Offset(0.05, 0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0.05, 0),
          end: const Offset(-0.05, 0),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.05, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(_shakeCtrl);

    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    try {
      final auth = LocalAuthentication();
      final can = await auth.canCheckBiometrics;
      if (mounted) setState(() => _hasBiometrics = can);
      if (can) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _tryBiometric();
      }
    } catch (_) {}
  }

  Future<void> _tryBiometric() async {
    if (!mounted) return;
    try {
      final auth = LocalAuthentication();
      final ok = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.appLockBiometricReason,
      );
      if (ok && mounted) widget.onUnlocked();
    } catch (_) {}
  }

  Future<void> _onDigit(String d) async {
    if (_lockedOut || _pin.length >= 4 || _verifying) return;
    setState(() => _pin += d);
    if (_pin.length == 4) {
      setState(() => _verifying = true);
      await _verify();
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty && !_lockedOut) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _verify() async {
    final stored = await _storage.read(key: PrefsKeys.appLockPinHash);
    final input = sha256.convert(utf8.encode(_pin)).toString();
    if (stored == input) {
      widget.onUnlocked();
      return;
    }
    if (!mounted) return;
    await _shakeCtrl.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _pin = '';
      _attempts++;
    });
    if (_attempts >= 3) _startLockout();
  }

  void _startLockout() {
    setState(() {
      _lockedOut = true;
      _lockoutSeconds = 30;
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _lockoutSeconds--);
      if (_lockoutSeconds <= 0) {
        t.cancel();
        setState(() {
          _lockedOut = false;
          _attempts = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.4,
            colors: [Color(0xFF2A1020), Color(0xFF120A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              const Text('🌙', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Luna',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              SlideTransition(
                position: _shakeAnim,
                child: PinDots(filled: _pin.length),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: _lockedOut
                    ? Text(
                        l10n.appLockTryAgain(_lockoutSeconds),
                        style: TextStyle(
                          color: Colors.red.shade300,
                          fontSize: 13,
                        ),
                      )
                    : Text(
                        l10n.appLockEnterPin,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: PinNumPad(
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                  leftAction: _hasBiometrics
                      ? PinButton(
                          onTap: _tryBiometric,
                          child: const Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                            size: 28,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
