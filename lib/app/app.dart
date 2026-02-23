import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/app/theme.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:task_ai/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:task_ai/features/home/presentation/screens/home_screen.dart';

class TaskAi extends StatelessWidget {
  const TaskAi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whale-task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: appDarkTheme,
        textTheme: GoogleFonts.interTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Theme.of(context).colorScheme.primary.withAlpha(128),
          selectionHandleColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
