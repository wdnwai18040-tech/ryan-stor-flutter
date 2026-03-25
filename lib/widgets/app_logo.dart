import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTitle;

  const AppLogo({
    super.key,
    this.size = 96,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icon/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text(
            'متجر الريان',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
          ),
        ],
      ],
    );
  }
}
