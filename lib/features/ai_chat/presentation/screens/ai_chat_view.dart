import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/core/widgets/custom_snackbar.dart';
import 'package:task_ai/features/ai_chat/presentation/widgets/chat_widgets.dart';

class AIChatView extends StatefulWidget {
  const AIChatView({super.key});

  @override
  State<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _chatCollection => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('ai_chat_messages');

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _uid.isEmpty) return;

    _controller.clear();
    setState(() => _isLoading = true);

    try {
      await _chatCollection.add({
        "role": "user",
        "text": text,
        "createdAt": FieldValue.serverTimestamp(),
      });

      final historySnapshot = await _chatCollection
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final history = historySnapshot.docs.reversed.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "role": data["role"] == "user" ? "user" : "model",
          "parts": [
            {"text": data["text"]},
          ],
        };
      }).toList();

      final result = await FirebaseFunctions.instance
          .httpsCallable('chatWithAI')
          .call({"prompt": text, "history": history});

      await _chatCollection.add({
        "role": "model",
        "text": result.data['text'],
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, "Failed to send message");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _buildHeader(colorScheme),
        _buildMessageList(colorScheme),
        _buildActionChips(context),
        Padding(
          padding: const EdgeInsets.all(24),
          child: ChatInputField(
            controller: _controller,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
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
            child: Icon(LucideIcons.bot, color: colorScheme.primary, size: 24),
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
    );
  }

  Widget _buildMessageList(ColorScheme colorScheme) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _chatCollection
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
            return _buildEmptyState(colorScheme);
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });

          return ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: ChatBubble(
                  text: data["text"] ?? '',
                  isUser: data["role"] == "user",
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
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
            "No messages yet.\nStart a conversation!",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: colorScheme.onSecondary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            ChatActionChip(label: 'Add to Calendar', onTap: () {}),
            ChatActionChip(label: 'Set Priority', onTap: () {}),
            ChatActionChip(label: 'Remind me in 1hr', onTap: () {}),
          ],
        ),
      ),
    );
  }
}
