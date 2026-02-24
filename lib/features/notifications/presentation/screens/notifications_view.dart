import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'Mark all as read',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSecondary.withAlpha(150),
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(height: 48, text: 'Reminders'),
              Tab(height: 48, text: 'History'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildRemindersTab(context), _buildHistoryTab(context)],
          ),
        ),
      ],
    );
  }

  Widget _buildRemindersTab(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildSectionHeader(context, 'TODAY'),
        _buildNotificationTile(
          context,
          icon: LucideIcons.calendar_clock,
          title: 'Project Proposal Due',
          subtitle:
              'The final draft for the Phoenix Project needs to be submitted to the board...',
          time: '2 hours left',
          tag: 'HIGH PRIORITY',
          tagColor: Theme.of(context).colorScheme.secondary,
          isNew: true,
        ),
        _buildNotificationTile(
          context,
          icon: LucideIcons.users,
          title: 'Team Stand-up',
          subtitle:
              'Sync with the design team about the new dashboard mockups and flow.',
          time: '10:30 AM',
          tag: 'In 15 minutes',
          tagColor: Theme.of(context).colorScheme.tertiary,
          isNew: true,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'YESTERDAY'),
        _buildNotificationTile(
          context,
          icon: LucideIcons.circle_check,
          title: 'Weekly Review Completed',
          subtitle:
              "You've finished 24 tasks this week! Great job staying productive.",
          time: '8:45 PM',
          isNew: false,
        ),
        _buildNotificationTile(
          context,
          icon: LucideIcons.message_circle,
          title: 'Sarah Jenkins mentioned you',
          subtitle:
              '"Can you double check the color contrast on the primary button?"',
          time: '2:12 PM',
          isNew: false,
          avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'OCTOBER 24'),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Icon(
                LucideIcons.clock_3,
                color: Theme.of(context).colorScheme.onSecondary.withAlpha(50),
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Older notifications are archived automatically after 30 days.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withAlpha(100),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    return const Center(
      child: Text('History Content', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSecondary.withAlpha(100),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    String? tag,
    Color? tagColor,
    bool isNew = false,
    String? avatarUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew
              ? Theme.of(context).colorScheme.primary.withAlpha(40)
              : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (avatarUrl != null)
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl))
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSecondary.withAlpha(180),
                    height: 1.4,
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (tagColor ??
                                      Theme.of(context).colorScheme.primary)
                                  .withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color:
                                tagColor ??
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• $time',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondary.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSecondary.withAlpha(120),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
