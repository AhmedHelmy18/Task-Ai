import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/ai_chat/presentation/widgets/chat_widgets.dart';

class MessageListView extends StatelessWidget {
  final String chatId;
  final CollectionReference messagesCollection;
  final ScrollController scrollController;

  const MessageListView({
    super.key,
    required this.chatId,
    required this.messagesCollection,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (chatId == 'new') {
      return _buildEmptyState(
        colorScheme,
        "No messages yet.\nStart a conversation!",
      );
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: messagesCollection
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading chat",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState(
              colorScheme,
              "No messages yet.\nStart a conversation!",
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              );
            }
          });

          return ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ChatBubble(
                  text: data["content"] ?? '',
                  isUser: data["role"] == "user",
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bot,
            color: colorScheme.primary.withAlpha(100),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colorScheme.onSecondary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}