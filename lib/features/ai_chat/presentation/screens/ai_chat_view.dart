import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class AIChatView extends StatelessWidget {
  const AIChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.bot,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Task Assistant',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online & Ready',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: colorScheme.onSecondary.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                LucideIcons.ellipsis_vertical,
                color: colorScheme.onSecondary.withAlpha(150),
              ),
            ],
          ),
        ),

        // Chat Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 20),
                _buildAIMessage(
                  context,
                  "Hello! I'm your task assistant. What can I help you remember today?",
                ),
                const SizedBox(height: 24),
                _buildUserMessage(
                  context,
                  "I need to finalize the quarterly budget review.",
                ),
                const SizedBox(height: 24),
                _buildAIMessage(
                  context,
                  "Got it! Would you like me to set a deadline for that or perhaps suggest some sub-tasks?",
                ),
              ],
            ),
          ),
        ),

        // Action Chips
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildActionChip(context, 'Add to Calendar'),
                _buildActionChip(context, 'Set Priority'),
                _buildActionChip(context, 'Remind me in 1hr'),
              ],
            ),
          ),
        ),

        // Input Field
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withAlpha(30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colorScheme.secondary.withAlpha(40)),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.paperclip,
                  color: colorScheme.onSecondary.withAlpha(150),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type a command...',
                      hintStyle: GoogleFonts.inter(
                        color: colorScheme.onSecondary.withAlpha(100),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.send_horizontal,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.mic,
                  color: colorScheme.onSecondary.withAlpha(150),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10), // Space for fab gap if needed
      ],
    );
  }

  Widget _buildAIMessage(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.primary.withAlpha(40),
          child: Icon(LucideIcons.bot, color: colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withAlpha(30),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white.withAlpha(230),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessage(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondary.withAlpha(60)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
