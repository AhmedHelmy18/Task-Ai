import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/auth/presentation/widgets/auth_field_label.dart';
import '../widgets/create_task_widgets.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Task',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const AuthFieldLabel(text: 'TASK NAME'),
                    const SizedBox(height: 8),
                    _buildTextField(context, hint: 'What needs to be done?'),
                    const SizedBox(height: 24),
                    const AuthFieldLabel(text: 'DESCRIPTION'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      context,
                      hint: 'Add more details about this task...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 32),
                    const AIAssistantSection(),
                    const SizedBox(height: 32),
                    const AuthFieldLabel(text: 'SETTINGS'),
                    const SizedBox(height: 12),
                    SettingTile(
                      label: 'Reminder Time',
                      value: 'Today, 4:00 PM',
                      icon: LucideIcons.bell,
                      iconColor: Theme.of(context).colorScheme.secondary,
                    ),
                    SettingTile(
                      label: 'Recurring',
                      value: 'Daily, Weekly, Monthly',
                      icon: LucideIcons.repeat,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                    ),
                    SettingTile(
                      label: 'Custom Sound Select',
                      value: 'Default (Crystal)',
                      icon: LucideIcons.volume_2,
                      iconColor: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.circle_check, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Save Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String hint,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withAlpha(40)),
      ),
      child: TextField(
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: colorScheme.onSecondary.withAlpha(120),
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
