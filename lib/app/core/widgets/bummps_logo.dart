import 'package:flutter/material.dart';

class BummpsLogo extends StatelessWidget {
  const BummpsLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/bummps-icon.png',
            height: 62,
            fit: BoxFit.contain,
          ),
          // const SizedBox(width: 2),
          Transform.translate(
            offset: const Offset(0, 6),
            child: Image.asset(
              'assets/images/bummps..png',
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/bummps-singin-view-icon.png',
          height: 130,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 6),
        Image.asset(
          'assets/images/bummps..png',
          height: 40,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}