import 'package:flutter/material.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i < filled;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.white : Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: active ? 1.0 : 0.3),
            ),
          ),
        );
      }),
    );
  }
}

class PinNumPad extends StatelessWidget {
  const PinNumPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.leftAction,
  });

  final void Function(String) onDigit;
  final VoidCallback onDelete;

  final Widget? leftAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NumRow(digits: const ['1', '2', '3'], onDigit: onDigit),
        const SizedBox(height: 14),
        _NumRow(digits: const ['4', '5', '6'], onDigit: onDigit),
        const SizedBox(height: 14),
        _NumRow(digits: const ['7', '8', '9'], onDigit: onDigit),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            leftAction ?? const SizedBox(width: 72, height: 72),
            PinButton(
              onTap: () => onDigit('0'),
              child: const Text(
                '0',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            PinButton(
              onTap: onDelete,
              child: const Icon(
                Icons.backspace_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumRow extends StatelessWidget {
  const _NumRow({required this.digits, required this.onDigit});

  final List<String> digits;
  final void Function(String) onDigit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map(
            (d) => PinButton(
              onTap: () => onDigit(d),
              child: Text(
                d,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class PinButton extends StatelessWidget {
  const PinButton({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
