import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:whale_task/features/ai_chat/presentation/screens/ai_chat_view.dart';
import 'package:whale_task/features/home/presentation/widgets/dashboard_widgets.dart';
import 'package:whale_task/features/tasks/presentation/screens/task_details_screen.dart';

class ListDetailScreen extends StatelessWidget {
  final String listId;
  final String title;

  const ListDetailScreen({
    super.key,
    required this.listId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AIChatView(listId: listId, listTitle: title),
                ),
              );
            },
            icon: const Icon(LucideIcons.sparkles, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('listId', isEqualTo: listId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data?.docs ?? [];
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    color: colorScheme.primary.withAlpha(80),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tasks in this list yet.\nUse Chat to generate some!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final data = tasks[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Untitled';
              final reminderTimeRaw = data['reminderTime'];
              DateTime? reminderTime;
              if (reminderTimeRaw is Timestamp) {
                reminderTime = reminderTimeRaw.toDate();
              } else if (reminderTimeRaw is String) {
                reminderTime = DateTime.tryParse(reminderTimeRaw);
              }

              IconData icon = LucideIcons.calendar;
              Color iconColor = Colors.blue;

              final lowerTitle = title.toLowerCase();
              if (lowerTitle.contains('sync') ||
                  lowerTitle.contains('meeting')) {
                icon = LucideIcons.refresh_ccw;
                iconColor = const Color(0xFF818CF8);
              } else if (lowerTitle.contains('call') ||
                  lowerTitle.contains('phone')) {
                icon = LucideIcons.phone;
                iconColor = const Color(0xFF34D399);
              } else if (lowerTitle.contains('doc') ||
                  lowerTitle.contains('write')) {
                icon = LucideIcons.file_text;
                iconColor = const Color(0xFFFBBF24);
              } else if (lowerTitle.contains('email') ||
                  lowerTitle.contains('draft')) {
                icon = LucideIcons.mail;
                iconColor = const Color(0xFF38BDF8);
              }

              String timeStr = 'No reminder';
              if (reminderTime != null) {
                final now = DateTime.now();
                if (reminderTime.day == now.day) {
                  timeStr =
                  'Today, ${DateFormat('h:mm a').format(reminderTime)}';
                } else if (reminderTime.day == now.day + 1) {
                  timeStr =
                  'Tomorrow, ${DateFormat('h:mm a').format(reminderTime)}';
                } else {
                  timeStr = DateFormat('MMM d').format(reminderTime);
                }
              }

              final isCompleted = data['status'] == 'completed';

              return UpcomingTaskTile(
                title: title,
                subtitle: timeStr,
                icon: icon,
                iconBgColor: iconColor,
                isCompleted: isCompleted,
                onToggle: () {
                  tasks[index].reference.update({
                    'status': isCompleted ? 'todo' : 'completed',
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(taskData: data),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}