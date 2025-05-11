import 'package:flutter/material.dart'; // Required for Flutter widgets like Text, IconButton, etc.
import '../features/model/prompt.dart'; // Adjust the import based on your project structure
import 'package:ai_chat_app/features/services/prompt.dart'; // Ensure this import exists
import 'package:ai_chat_app/globals.dart'; // Ensure this import exists

class PromptMenu {
  static OverlayEntry? _entry;

  static List<Prompt>? globalPrompts;
  static List<Prompt>? privatePrompts;

  static Future<void> initializePrompts() async {
    globalPrompts = await PromptManage().getPrompt(isPublic: true); // Initialize global prompts
    privatePrompts = await PromptManage().getPrompt(isPublic: false); // Initialize private prompts

    // Sort prompts to ensure favorite prompts go first
    globalPrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
    privatePrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
  }

  static Future<void> _handleFavoritePrompt(Prompt prompt, BuildContext context) async {
    if (prompt.isFavorite == false) {
      // If already favorite, remove it
      bool favorite = await PromptManage().addFavoritePrompt(prompt.id);
      if (favorite) {
        prompt.isFavorite = !prompt.isFavorite; // Toggle favorite status
        if (prompt.isPublic) {
          globalPrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
        } else {
          privatePrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
        }
        (context as Element).markNeedsBuild(); // Trigger UI update
      }
     else {
        // Handle error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite status!')),
        );
      }
    } else {
      // If not favorite, add it
      bool favorite = await PromptManage().removeFavoritePrompt(prompt.id);

            if (favorite) {
        prompt.isFavorite = !prompt.isFavorite; // Toggle favorite status
        if (prompt.isPublic) {
          globalPrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
        } else {
          privatePrompts?.sort((a, b) => (b.isFavorite ? 1 : 0).compareTo(a.isFavorite ? 1 : 0));
        }
        (context as Element).markNeedsBuild(); // Trigger UI update
      }
     else {
        // Handle error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite status!')),
        );
      }
    }

  }

  static void show({
    required BuildContext context,
    required LayerLink link,
    required TextEditingController controller,
  }) async {
    await initializePrompts(); // Load prompts
    _entry = OverlayEntry(
      builder: (context) {
  return Positioned(
    width: 350,
    child: CompositedTransformFollower(
      link: link,
      offset: const Offset(0, -250),
      showWhenUnlinked: false,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: StatefulBuilder(
          builder: (context, setState) {
            // Define the refresh function to trigger UI updates
            void refresh() async {
              await initializePrompts();
              setState(() {}); // Refresh UI
            }

            return Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C003E),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Prompt Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: hide,
                        ),
                      ],
                    ),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Global Prompts'),
                        Tab(text: 'Private Prompts'),
                      ],
                    ),
                    SizedBox(
                      height: 200,
                      child: TabBarView(
                        children: [
                          _buildPromptList(globalPrompts, controller, context, refresh),
                          _buildPromptList(privatePrompts, controller, context, refresh),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton.icon(
                      onPressed: () {
                        hide(); // Close the menu
                        _showAddPromptDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Prompt"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
    );
    Overlay.of(context).insert(_entry!);
  }



  static Widget _buildPromptList(List<Prompt>? prompts, TextEditingController controller, BuildContext context, VoidCallback refresh) {
    return ListView.builder(
      itemCount: prompts?.length,
      itemBuilder: (context, index) {
        final prompt = prompts?[index];
        return ListTile(
          title: Text(prompt!.title),
          subtitle: Text(prompt.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!prompt.isPublic) ...[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    hide(); // Close the menu
                    _showEditPromptDialog(context, prompt);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool deleted = await PromptManage().deletePrompt(prompt.id);
                    if (deleted) {
                      refresh(); // Refresh the list after deletion
                    } else {
                      scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(content: Text('Failed to delete prompt!')),
                      );
                    }
                  },
                ),
              ],
              IconButton(
                icon: Icon(
                  prompt.isFavorite ? Icons.star : Icons.star_border,
                  color: prompt.isFavorite ? Colors.yellow : Colors.grey,
                ),
                onPressed: () async {
                  await _handleFavoritePrompt(prompt, context); // Toggle favorite status
                  refresh(); // Refresh the list
                },
              ),
            ],
          ),
          onTap: () {
            controller.text = prompt.content; // Insert selected prompt
            hide(); // Close the menu
          },
        );
      },
    );
  }

  static void _showEditPromptDialog(BuildContext context, Prompt prompt) {
    final titleController = TextEditingController(text: prompt.title);
    final contentController = TextEditingController(text: prompt.content);
    final descriptionController = TextEditingController(text: prompt.description);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  bool result = await PromptManage().updatePrompt(
                    id: prompt.id,
                    title: titleController.text,
                    content: contentController.text,
                    description: descriptionController.text,
                  );
                  if (!result) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Faied to update prompt!')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext); // Close the dialog
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Prompt updated successfully!')),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

static void _showAddPromptDialog(BuildContext context) {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Add New Prompt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  bool result = await PromptManage().createPrompt(
                    title: titleController.text,
                    content: contentController.text,
                    description: descriptionController.text,
                  );
                  if (!result) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Failed to add prompt!')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext); // Close the dialog
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Prompt added successfully!')),
                  );
                  // Close the menu
              }
            },
            child: const Text('Add Prompt'),
          ),
        ],
      );
    },
  );
}

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
