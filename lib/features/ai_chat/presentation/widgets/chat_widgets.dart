import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primary.withAlpha(40),
            child: Icon(LucideIcons.bot, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser
                  ? colorScheme.primary
                  : colorScheme.secondary.withAlpha(30),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                bottomRight: isUser ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: isUser ? Colors.white : Colors.white.withAlpha(230),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
              controller: controller,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
              onSubmitted: (_) => onSend(),
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
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      LucideIcons.send_horizontal,
                      color: Colors.white,
                      size: 18,
                    ),
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
    );
  }
}

class ChatActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ChatActionChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
