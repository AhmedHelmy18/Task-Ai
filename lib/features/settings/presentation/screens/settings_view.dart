import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/settings/presentation/widgets/logout_button.dart';
import 'package:whale_task/features/settings/presentation/widgets/profile_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/setting_tile.dart';
import 'package:whale_task/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:whale_task/features/settings/presentation/widgets/theme_selector.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
                name: user?.displayName ?? 'Alex Thompson',
                email: user?.email ?? 'alex.t@design.com',
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
                value: true,
                onChanged: (v) {},
              ),
              const SizedBox(height: 12),
              SettingsToggleTile(
                icon: LucideIcons.mail,
                title: 'Marketing Emails',
                subtitle: 'Updates and offers',
                value: false,
                onChanged: (v) {},
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
              const LogoutButton(),

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
