import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/features/home/presentation/widgets/dashboard_widgets.dart';
import 'package:task_ai/features/calendar/presentation/screens/calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning, ${user?.displayName?.split(' ').first ?? 'User'}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have 5 tasks for today',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(50),
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
                        child: const Icon(
                          LucideIcons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Premium Calendar Header Action
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarScreen(),
                  ),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(200),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(60),
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
                            'See your upcoming internal schedule',
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withAlpha(100),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const ProgressCard(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Priority',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 210,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  TaskCard(
                    title: 'Finalize Project Proposal',
                    description: 'Review market analysis & team capacity',
                    priority: 'HIGH PRIORITY',
                    duration: '15 min required',
                    priorityColor: Theme.of(context).colorScheme.secondary,
                  ),
                  TaskCard(
                    title: 'Review Quarterly Budget',
                    description: 'Approve pending expenses and forecasts',
                    priority: 'URGENT',
                    duration: '30 min required',
                    priorityColor: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  LucideIcons.sliders_horizontal,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 20),
            UpcomingTaskTile(
              title: 'Weekly Sync',
              subtitle: 'Recurring • Tomorrow, 10:00 AM',
              icon: LucideIcons.repeat,
              iconBgColor: Theme.of(context).colorScheme.tertiary,
            ),
            UpcomingTaskTile(
              title: 'Call Client - Sarah',
              subtitle: 'One-time • Today, 2:00 PM',
              icon: LucideIcons.phone,
              iconBgColor: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            UpcomingTaskTile(
              title: 'Update Documentation',
              subtitle: 'Recurring • Wednesday',
              icon: LucideIcons.file_text,
              iconBgColor: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
            UpcomingTaskTile(
              title: 'Draft Newsletter',
              subtitle: 'One-time • Friday',
              icon: LucideIcons.mail,
              iconBgColor: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
