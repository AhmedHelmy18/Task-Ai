import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:whale_task/core/widgets/custom_snackbar.dart';
import 'package:whale_task/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:whale_task/features/tasks/presentation/widgets/create_task_widgets.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  DateTime? _reminderTime;
  String _recurring = 'None';
  String _selectedSound = 'Crystal';

  Future<void> _pickReminderTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          _reminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _pickRecurring() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = ['None', 'Daily', 'Weekly', 'Monthly'];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(
                  option,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                trailing: _recurring == option
                    ? Icon(
                        LucideIcons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _recurring = option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _pickSound() {
    showDialog(
      context: context,
      builder: (context) {
        final sounds = ['Crystal', 'Bell', 'Digital', 'Zen'];
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Select Sound',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: sounds.map((sound) {
              return ListTile(
                title: Text(
                  sound,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                trailing: _selectedSound == sound
                    ? Icon(
                        LucideIcons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedSound = sound);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      CustomSnackBar.showError(context, "Please enter a task name");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFunctions.instance.httpsCallable('createTask').call({
        "title": title,
        "description": _descController.text.trim(),
        "status": "todo",
        "reminderTime": _reminderTime?.toIso8601String(),
        "recurring": _recurring,
        "sound": _selectedSound,
      });

      if (mounted) {
        CustomSnackBar.showSuccess(context, "Task created successfully");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, "Failed to create task");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveTask,
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
                    _buildTextField(
                      context,
                      controller: _titleController,
                      hint: 'What needs to be done?',
                    ),
                    const SizedBox(height: 24),
                    const AuthFieldLabel(text: 'DESCRIPTION'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      context,
                      controller: _descController,
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
                      value: _reminderTime == null
                          ? 'Not set'
                          : DateFormat('MMM d, h:mm a').format(_reminderTime!),
                      icon: LucideIcons.bell,
                      iconColor: Theme.of(context).colorScheme.secondary,
                      onTap: _pickReminderTime,
                    ),
                    SettingTile(
                      label: 'Recurring',
                      value: _recurring,
                      icon: LucideIcons.repeat,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      onTap: _pickRecurring,
                    ),
                    SettingTile(
                      label: 'Custom Sound Select',
                      value: _selectedSound,
                      icon: LucideIcons.volume_2,
                      iconColor: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer,
                      onTap: _pickSound,
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
                  onPressed: _isLoading ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.circle_check, size: 20),
                            const SizedBox(width: 8),
                            const Text(
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
    required TextEditingController controller,
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
        controller: controller,
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
