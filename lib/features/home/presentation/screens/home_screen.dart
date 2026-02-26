import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/home/presentation/widgets/dashboard_widgets.dart';
import 'package:whale_task/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:intl/intl.dart';
import 'package:whale_task/features/home/presentation/widgets/dashboard_widgets.dart';
import 'package:whale_task/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:whale_task/features/tasks/presentation/screens/task_details_screen.dart';
import 'package:whale_task/features/lists/presentation/screens/list_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        final tasks = snapshot.data?.docs ?? [];
        final completedTasks = tasks.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'completed';
        }).length;
        final totalTasks = tasks.length;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning, ${user?.displayName?.split(' ').first ?? 'User'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You have $totalTasks tasks in total',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildProfileAvatar(user, context),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCalendarCard(context),
                  const SizedBox(height: 32),
                  ProgressCard(
                    completedCount: completedTasks,
                    totalCount: totalTasks,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'My Lists'),
                  const SizedBox(height: 16),
                  _buildListsSection(context),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Priority Tasks'),
                  const SizedBox(height: 16),
                  _buildPriorityTasks(tasks, context),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, 'Upcoming Tasks', showFilter: true),
                  const SizedBox(height: 20),
                  _buildUpcomingTasks(tasks, context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('lists')
          .where('userId', isEqualTo: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'No lists yet',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        final lists = snapshot.data!.docs;
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final data = lists[index].data() as Map<String, dynamic>;
              final id = lists[index].id;
              final title = data['title'] ?? 'Untitled';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ListDetailScreen(listId: id, title: title),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withAlpha(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.list_todo, color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(User? user, BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : null,
          child: user?.photoURL == null
              ? Icon(
                  LucideIcons.user,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                )
              : null,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: const Icon(LucideIcons.check, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(40),
              Theme.of(context).colorScheme.secondary.withAlpha(20),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(30),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withAlpha(60),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.calendar,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Calendar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See your upcoming schedule',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevron_right,
              color: Theme.of(context).colorScheme.onSecondary.withAlpha(100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    bool showFilter = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (showFilter)
          Icon(
            LucideIcons.sliders_horizontal,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 20,
          )
        else
          TextButton(
            onPressed: () {},
            child: Text(
              'View all',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriorityTasks(
    List<QueryDocumentSnapshot> tasks,
    BuildContext context,
  ) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text("No tasks yet", style: TextStyle(color: Colors.white54)),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final data = tasks[index].data() as Map<String, dynamic>;
          return TaskCard(
            title: data['title'] ?? 'Untitled',
            description: data['description'] ?? 'No description provided',
            priority: data['status'] == 'completed' ? 'COMPLETED' : 'PENDING',
            duration: 'Updated just now',
            priorityColor: data['status'] == 'completed'
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
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
      ),
    );
  }

  Widget _buildUpcomingTasks(
    List<QueryDocumentSnapshot> tasks,
    BuildContext context,
  ) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No upcoming tasks",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length > 4 ? 4 : tasks.length,
      itemBuilder: (context, index) {
        final data = tasks[index].data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Untitled';
        final recurring = data['recurring'] ?? 'None';
        final isRecurring = recurring != 'None';
        final reminderTimeRaw = data['reminderTime'];
        DateTime? reminderTime;
        if (reminderTimeRaw is Timestamp) {
          reminderTime = reminderTimeRaw.toDate();
        } else if (reminderTimeRaw is String) {
          reminderTime = DateTime.tryParse(reminderTimeRaw);
        }

        String timeStr = 'No reminder';
        if (reminderTime != null) {
          final now = DateTime.now();
          if (reminderTime.day == now.day) {
            timeStr = 'Today, ${DateFormat('h:mm a').format(reminderTime)}';
          } else if (reminderTime.day == now.day + 1) {
            timeStr = 'Tomorrow, ${DateFormat('h:mm a').format(reminderTime)}';
          } else {
            timeStr = DateFormat('EEEE').format(reminderTime);
          }
        }

        IconData icon = LucideIcons.calendar;
        Color iconColor = Colors.blue;

        final lowerTitle = title.toLowerCase();
        if (lowerTitle.contains('sync') || lowerTitle.contains('meeting')) {
          icon = LucideIcons.refresh_ccw;
          iconColor = const Color(0xFF818CF8);
        } else if (lowerTitle.contains('call') ||
            lowerTitle.contains('phone')) {
          icon = LucideIcons.phone;
          iconColor = const Color(0xFF34D399);
        } else if (lowerTitle.contains('doc') || lowerTitle.contains('write')) {
          icon = LucideIcons.file_text;
          iconColor = const Color(0xFFFBBF24);
        } else if (lowerTitle.contains('email') ||
            lowerTitle.contains('draft')) {
          icon = LucideIcons.mail;
          iconColor = const Color(0xFF38BDF8);
        }

        return UpcomingTaskTile(
          title: title,
          subtitle: '${isRecurring ? 'Recurring' : 'One-time'} • $timeStr',
          icon: icon,
          iconBgColor: iconColor,
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
  }
}
