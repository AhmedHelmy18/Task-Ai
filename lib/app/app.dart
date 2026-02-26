import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/app/theme.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_state.dart';
import 'package:whale_task/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:whale_task/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:whale_task/features/home/presentation/screens/home_screen.dart';
import 'package:whale_task/features/tasks/presentation/screens/create_task_screen.dart';
import 'package:whale_task/features/notifications/presentation/screens/notifications_view.dart';
import 'package:whale_task/features/settings/presentation/screens/settings_view.dart';
import 'package:whale_task/features/lists/presentation/screens/lists_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whale-task',
      debugShowCheckedModeBanner: false,
      theme: appTheme.copyWith(
        textTheme: GoogleFonts.interTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: appDarkTheme.primary.withAlpha(128),
          selectionHandleColor: appDarkTheme.primary,
        ),
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const MainAppShell();
          } else if (state is AuthNeedsVerification) {
            return const VerifyEmailScreen();
          } else if (state is AuthLoading || state is AuthInitial) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ListsScreen(),
    const NotificationsView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 32),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            LucideIcons.sparkles,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        color: Theme.of(context).colorScheme.primaryContainer,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, LucideIcons.house, 'HOME'),
            _buildNavItem(1, LucideIcons.list_todo, 'LISTS'),
            const SizedBox(width: 64),
            _buildNavItem(2, LucideIcons.bell, 'ALERTS'),
            _buildNavItem(3, LucideIcons.settings, 'SETTINGS'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondary.withAlpha(150),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSecondary.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}