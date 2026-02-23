import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.onSecondary.withAlpha(30))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSecondary.withAlpha(100),
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.onSecondary.withAlpha(30))),
      ],
    );
  }
}
