import 'package:flutter/material.dart';

class BummpsLogo extends StatelessWidget {
  const BummpsLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/bummps-icon.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 1),
          Image.asset(
            'assets/images/bummps..png',
            height: 24,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    return Column(
      children: [
        Image.asset(
          'assets/images/bummps-icon.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        Image.asset(
          'assets/images/bummps..png',
          height: 32,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}