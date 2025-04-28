import 'package:flutter/material.dart';
import '../features/model/prompt.dart'; // Adjust the import based on your project structure
import 'package:ai_chat_app/features/services/prompt.dart'; // Ensure this import exists

class PromptMenu {

  static List<Prompt>? globalPrompts;
  static List<Prompt>? privatePrompts;

  static Future<void> initializePrompts() async {
    globalPrompts = await PromptManage().getPrompt(isPublic: true); // Initialize global prompts
    privatePrompts = await PromptManage().getPrompt(isPublic: false); // Initialize private prompts
  }

    static void open({        
        required BuildContext context,
        required TextEditingController controller,
    }) async {  
        await initializePrompts(); // Load prompts

        showModalBottomSheet(
        context: context,
        builder: (context) {
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(tabs: [
                  Tab(text: 'Global Prompts'),
                  Tab(text: 'Private Prompts'),
                ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPromptList(globalPrompts, controller, context),
                      _buildPromptList(privatePrompts, controller, context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }


  
  static Widget _buildPromptList(
    List<Prompt>? prompts,
    TextEditingController controller,
    BuildContext context,
  ) {
    return ListView.builder(
      itemCount: prompts?.length ?? 0,
      itemBuilder: (context, index) {
        final prompt = prompts![index];
        return ListTile(
          title: Text(prompt.title),
          subtitle: Text(prompt.description),
          onTap: () {
            controller.text = prompt.content; // Insert selected prompt
            Navigator.pop(context); // Close menu
          },
        );
      },
    );
  }
}
