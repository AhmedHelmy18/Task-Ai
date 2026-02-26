import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/features/lists/presentation/screens/list_detail_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:whale_task/core/widgets/custom_snackbar.dart';

class ListsScreen extends StatelessWidget {
  const ListsScreen({super.key});

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _createList(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('New List', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'List name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await FirebaseFunctions.instance.httpsCallable('createList').call({
          'title': result,
        });
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, 'List created');
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(context, 'Failed to create list');
        }
      }
    }
  }

  Future<void> _renameList(
    BuildContext context,
    String listId,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Rename List', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'List name',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != currentTitle) {
      try {
        await FirebaseFunctions.instance.httpsCallable('renameList').call({
          'listId': listId,
          'title': result,
        });
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, 'List renamed');
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(context, 'Failed to rename list');
        }
      }
    }
  }

  Future<void> _deleteList(BuildContext context, String listId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete List', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this list and all its tasks and messages?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFunctions.instance.httpsCallable('deleteList').call({
          'listId': listId,
        });
        if (context.mounted) {
          CustomSnackBar.showSuccess(context, 'List deleted');
        }
      } catch (e) {
        if (context.mounted) {
          CustomSnackBar.showError(context, 'Failed to delete list');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Lists',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => _createList(context),
                icon: Icon(LucideIcons.plus, color: colorScheme.primary),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lists')
                .where('userId', isEqualTo: _uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.list_todo,
                        color: colorScheme.primary.withAlpha(100),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No lists yet.\nCreate your first one!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: colorScheme.onSecondary.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final listId = docs[index].id;
                  final title = data['title'] ?? 'Untitled List';
                  return Card(
                    color: colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.list_todo,
                          color: colorScheme.primary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              LucideIcons.pencil,
                              color: Colors.blue,
                              size: 20,
                            ),
                            onPressed: () =>
                                _renameList(context, listId, title),
                          ),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.trash_2,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteList(context, listId),
                          ),
                          Icon(
                            LucideIcons.chevron_right,
                            color: Colors.white.withAlpha(50),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListDetailScreen(listId: listId, title: title),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
