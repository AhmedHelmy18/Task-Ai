import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/settings/presentation/widgets/logout_button.dart';
import 'package:whale_task/features/settings/presentation/widgets/profile_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/setting_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:whale_task/features/settings/presentation/widgets/theme_selector.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:whale_task/features/settings/presentation/widgets/logout_button.dart';
import 'package:whale_task/features/settings/presentation/widgets/profile_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/setting_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:whale_task/features/settings/presentation/widgets/theme_selector.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _pushNotifications = true;
  bool _marketingEmails = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151932),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
            },
            child: Text(
              'LOG OUT',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                LucideIcons.search,
                color: Colors.white.withAlpha(150),
                size: 20,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              const SizedBox(height: 24),
              const SettingsSectionHeader(title: 'ACCOUNT'),
              ProfileTile(
                name: user?.displayName ?? 'User Name',
                email: user?.email ?? 'user@email.com',
                avatarUrl: user?.photoURL,
              ),
              const SizedBox(height: 12),
              const SettingsTile(
                icon: LucideIcons.lock,
                title: 'Security & Password',
              ),
              const SizedBox(height: 32),
              const SettingsSectionHeader(title: 'NOTIFICATIONS'),
              SettingsToggleTile(
                icon: LucideIcons.bell,
                title: 'Push Notifications',
                subtitle: 'Alerts on your lock screen',
                value: _pushNotifications,
                onChanged: (v) => setState(() => _pushNotifications = v),
              ),
              const SizedBox(height: 12),
              SettingsToggleTile(
                icon: LucideIcons.mail,
                title: 'Marketing Emails',
                subtitle: 'Updates and offers',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),
              const SizedBox(height: 32),
              const SettingsSectionHeader(title: 'REMINDER SOUNDS'),
              const SettingsDropdownTile(
                icon: LucideIcons.volume_2,
                title: 'Default Sound',
                value: 'Crystal Chime',
              ),
              const SizedBox(height: 32),
              const SettingsSectionHeader(title: 'APP THEME'),
              const ThemeSelector(),
              const SizedBox(height: 48),
              LogoutButton(onPressed: _showLogoutDialog),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'VERSION 2.4.1 (BUILD 890)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSecondary.withAlpha(80),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
