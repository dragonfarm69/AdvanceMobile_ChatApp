import 'package:flutter/material.dart';
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

  static hide() {
    _entry?.remove();
    _entry = null;
  }

  static void open({
    required BuildContext context,
    required LayerLink link,
    required TextEditingController controller,
  }) async {
    await initializePrompts(); // Load prompts

  _entry = OverlayEntry(
    builder: (context) => Positioned(
      // Use Positioned.fill to let CompositedTransformFollower handle position
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: const Offset(0, -250), // Adjust vertically above the text field
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 300,
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
                  const TabBar(tabs: [
                    Tab(text: 'Global Prompts'),
                    Tab(text: 'Private Prompts'),
                  ]),
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

    overlay?.insert(overlayEntry);
  }

  static Widget _buildList(List<Prompt> prompts, TextEditingController controller, BuildContext context) {
    return ListView.builder(
      itemCount: prompts.length,
      itemBuilder: (context, index) {
        final prompt = prompts[index];
        return ListTile(
          title: Text(prompt.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prompt.description),
              Text(prompt.content, style: TextStyle(color: Colors.grey)),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              prompt.isFavorite ? Icons.star : Icons.star_border,
              color: prompt.isFavorite ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              // Toggle favorite status
              prompt.isFavorite = !prompt.isFavorite;
              (context as Element).markNeedsBuild(); // Rebuild to reflect changes
            },
          ),
          onTap: () {
            controller.text = prompt.content;
            hide();
          },
        );
      },
    );
  }
}
