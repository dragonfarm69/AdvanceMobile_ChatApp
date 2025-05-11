import 'package:flutter/material.dart'; // Required for Flutter widgets like Text, IconButton, etc.
import '../features/model/prompt.dart'; // Adjust the import based on your project structure
import 'package:ai_chat_app/features/services/prompt.dart'; // Ensure this import exists

class PromptMenu {
  static OverlayEntry? _entry;

  static List<Prompt>? globalPrompts;
  static List<Prompt>? privatePrompts;

  static Future<void> initializePrompts() async {
    globalPrompts = await PromptManage().getPrompt(isPublic: true); // Initialize global prompts
    privatePrompts = await PromptManage().getPrompt(isPublic: false); // Initialize private prompts
  }

  static void show({
    required BuildContext context,
    required LayerLink link,
    required TextEditingController controller,
  }) async {
    await initializePrompts(); // Load prompts
    _entry = OverlayEntry(
      builder: (context) => Positioned(
        width: 350, // Adjust width as needed
        child: CompositedTransformFollower(
          link: link,
          offset: const Offset(0, -250), // Slightly higher than the target
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
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
                          onPressed: hide, // Close the menu
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
                          _buildPromptList(globalPrompts, controller, context),
                          _buildPromptList(privatePrompts, controller, context),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton.icon(
                      onPressed: () {
                        hide();
                        _showAddPromptDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Prompt"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }



  static Widget _buildPromptList(List<Prompt>? prompts, TextEditingController controller, BuildContext context) {
    return ListView.builder(
      itemCount: prompts?.length,
      itemBuilder: (context, index) {
        final prompt = prompts?[index];
        return ListTile(
          title: Text(prompt!.title),
          subtitle: Text(prompt.description),
          trailing: IconButton(
            icon: Icon(
              prompt.isFavorite ? Icons.star : Icons.star_border,
              color: prompt.isFavorite ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              prompt.isFavorite = !prompt.isFavorite; // Toggle favorite status
              // Optionally, update the backend or state management here
            },
          ),
          onTap: () {
            controller.text = prompt.content; // Insert selected prompt
            hide(); // Close the menu
          },
        );
      },
    );
  }

  static void _showAddPromptDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () 
              {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  PromptManage().createPrompt(
                    title: titleController.text,
                    content: contentController.text,
                    description: descriptionController.text, // Set to true if you want to make it public
                  ).then((_) {
                    // Handle success (e.g., show a snackbar)
                    SnackBar(
                      content: const Text('Prompt added successfully!'),
                      duration: const Duration(seconds: 2),
                    );
                    Navigator.pop(context); // Close dialog
                    initializePrompts(); // Refresh prompts
                  }).catchError((error) {
                    // Handle error (e.g., show a snackbar)
                    SnackBar(
                      content: const Text('Failed to add prompt!'),
                      duration: const Duration(seconds: 2),
                    );// Close dialog
                  });
                } else {
                  // Show error message (e.g., using a snackbar)
                  SnackBar(
                    content: const Text('Please fill in all fields!'),
                    duration: const Duration(seconds: 2),
                  );
                }
              }, child: const Text('Add Prompt')),
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
