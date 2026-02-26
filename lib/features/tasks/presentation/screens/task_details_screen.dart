import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:whale_task/core/widgets/custom_snackbar.dart';
import 'package:whale_task/features/ai_chat/presentation/screens/ai_chat_view.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;

  const TaskDetailsScreen({super.key, required this.taskData});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _pushNotifications = true;
  bool _customSounds = false;

  void _manageWithAI() {
    final listId = widget.taskData['listId'];
    final listTitle = widget.taskData['listTitle'] ?? 'Task Context';

    if (listId == null) {
      CustomSnackBar.showError(context, "No list associated with this task.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatView(listId: listId, listTitle: listTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = widget.taskData['title'] ?? 'Untitled Task';
    final description =
        widget.taskData['description'] ?? 'No description provided';
    final status = (widget.taskData['status'] ?? 'todo')
        .toString()
        .toUpperCase();

    final reminderTimeRaw = widget.taskData['reminderTime'];
    DateTime? reminderTime;
    if (reminderTimeRaw is Timestamp) {
      reminderTime = reminderTimeRaw.toDate();
    } else if (reminderTimeRaw is String) {
      reminderTime = DateTime.tryParse(reminderTimeRaw);
    }

    final recurring = widget.taskData['recurring'] ?? 'None';

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task Details',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, color: Colors.white, size: 20),
            onPressed: () {
              CustomSnackBar.showSuccess(
                context,
                "Edit Task feature coming soon!",
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F3C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3B67FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status == 'TODO' ? 'IN PROGRESS' : status,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3B67FF),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.white.withAlpha(150),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildModernInfoCard(
                context,
                icon: LucideIcons.calendar,
                label: 'Due Date',
                value: reminderTime != null
                    ? DateFormat('MMM d, yyyy').format(reminderTime)
                    : 'Not set',
                iconColor: const Color(0xFF3B67FF),
              ),
              const SizedBox(height: 16),
              _buildModernInfoCard(
                context,
                icon: LucideIcons.repeat,
                label: 'Recurring Info',
                value: recurring == 'None'
                    ? 'One-time task'
                    : 'Repeats $recurring',
                iconColor: const Color(0xFF3B67FF),
              ),
              const SizedBox(height: 32),
              Text(
                'NOTIFICATIONS & REMINDERS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(100),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151932),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildSwitchTile(
                      label: 'Push Notifications',
                      icon: LucideIcons.bell,
                      value: _pushNotifications,
                      onChanged: (val) =>
                          setState(() => _pushNotifications = val),
                    ),
                    Divider(color: Colors.white.withAlpha(20), height: 1),
                    _buildSwitchTile(
                      label: 'Custom Sounds',
                      icon: LucideIcons.volume_2,
                      value: _customSounds,
                      onChanged: (val) => setState(() => _customSounds = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _manageWithAI,
                  icon: const Icon(
                    LucideIcons.sparkles,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Manage with AI',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151932),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withAlpha(80),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withAlpha(150), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF1D4ED8),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withAlpha(100),
          ),
        ],
      ),
    );
  }
}
