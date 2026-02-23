import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/app/theme.dart';
import 'package:task_ai/features/auth/presentation/screens/onboarding_screen.dart';

class TaskAi extends StatelessWidget {
  const TaskAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whale-task',
      theme: ThemeData(
        colorScheme: appDarkTheme,
        textTheme: GoogleFonts.interTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Theme.of(context).colorScheme.primary.withAlpha(128),
          selectionHandleColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
