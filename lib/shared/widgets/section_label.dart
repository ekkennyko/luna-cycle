import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.text,
    required this.color,
    this.letterSpacing = 1,
    this.fontWeight,
  });

  final String text;
  final Color color;
  final double letterSpacing;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight,
      ),
    );
  }
}
