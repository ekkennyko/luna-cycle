import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/features/settings/presentation/widgets/pin_pad.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;
  String? _error;
  bool _saving = false;

  static const _storage = FlutterSecureStorage();

  void _onDigit(String d) {
    if (_pin.length >= 4 || _saving) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) Future.microtask(_onPinComplete);
  }

  void _onDelete() {
    if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _onPinComplete() async {
    if (!_confirming) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
        _confirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        setState(() => _saving = true);
        final hash = sha256.convert(utf8.encode(_pin)).toString();
        await _storage.write(key: PrefsKeys.appLockPinHash, value: hash);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(PrefsKeys.appLockEnabled, true);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _pin = '';
          _firstPin = '';
          _confirming = false;
          _error = AppLocalizations.of(context)!.appLockPinMismatch;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _confirming ? l10n.appLockConfirmPin : l10n.appLockSetPin;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white54,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.4,
            colors: [Color(0xFF2A1020), Color(0xFF120A0A)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const Spacer(),
              const Text('🔐', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              PinDots(filled: _pin.length),
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: _error != null
                    ? Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                      )
                    : const SizedBox.shrink(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: PinNumPad(onDigit: _onDigit, onDelete: _onDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
