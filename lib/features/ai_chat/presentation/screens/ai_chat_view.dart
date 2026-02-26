import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/core/widgets/custom_snackbar.dart';
import 'package:whale_task/features/ai_chat/presentation/widgets/chat_widgets.dart';
import 'package:whale_task/features/ai_chat/presentation/widgets/message_list_view.dart';

class AIChatView extends StatefulWidget {
  final String listId;
  final String listTitle;

  const AIChatView({super.key, required this.listId, required this.listTitle});

  @override
  State<AIChatView> createState() => _AIChatViewState();
}

class _AIChatViewState extends State<AIChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _messagesCollection => FirebaseFirestore.instance
      .collection('lists')
      .doc(widget.listId)
      .collection('messages');

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _uid.isEmpty) return;

    _controller.clear();
    setState(() => _isLoading = true);

    try {
      // Fetch history for AI
      final historySnapshot = await _messagesCollection
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final history = historySnapshot.docs.reversed.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "role": data["role"] == "user" ? "user" : "model",
          "parts": [
            {"text": data["content"]},
          ],
        };
      }).toList();

      await FirebaseFunctions.instance.httpsCallable('chatWithAI').call({
        "prompt": text,
        "history": history,
        "listId": widget.listId,
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

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            MessageListView(
              chatId: widget.listId,
              messagesCollection: _messagesCollection,
              scrollController: _scrollController,
            ),
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
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevron_left, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.listTitle,
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
                    'Online',
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
            ChatActionChip(
              label: 'Add Task',
              onTap: () {
                _controller.text = "Remind me to ";
              },
            ),
            ChatActionChip(
              label: 'Summarize',
              onTap: () {
                _controller.text = "Can you summarize our conversation?";
              },
            ),
          ],
        ),
      ),
    );
  }
}