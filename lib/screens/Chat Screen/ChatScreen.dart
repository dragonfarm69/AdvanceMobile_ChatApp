import 'package:flutter/material.dart';
import '../../features/services/ai_chat.dart';
import '../../features/model/chat_message.dart';
import '../../features/model/assistant.dart';
import '../../Components/PromptMenu.dart';

class ChatScreen extends StatefulWidget {
  final String? content;
  final String? message; // holds the passed message Default value for selected assistant
  final String conversationId; // holds the passed conversation ID
  // Removed redundant final variable declaration
  const ChatScreen({super.key, this.content, this.message, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = []; // Holds the chat messages
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  String? get content => widget.content;
  String? get message => widget.message; // holds the passed message
  String get conversationId => widget.conversationId; // holds the passed conversation ID
  bool _isLoading = false;
  AiChat chat = AiChat(); // Instance of the Chat class

  PromptMenu promptMenu = PromptMenu(); // Instance of the PromptMenu class

  List<Map<String, Assistant>> assistants = [
    {"assistant": Assistant(name: 'Claude 3 Haiku', id: 'claude-3-haiku-20240307', model: 'dify', tokenCost: 1)},
    {"assistant": Assistant(name: 'Claude 35 Sonnet', id: 'claude-3-5-sonnet-20240620', model: 'dify', tokenCost: 3)},
    {"assistant": Assistant(name: 'Gemini 1.5 Flash', id: 'gemini-1.5-flash-latest', model: 'dify', tokenCost: 1)},
    {"assistant": Assistant(name: 'Gemini 1.5 Pro', id: 'gemini-1.5-pro-latest', model: 'dify', tokenCost: 5)},
    {"assistant": Assistant(name: 'GPT 4o', id: 'gpt-4o', model: 'dify', tokenCost: 5)},
    {"assistant": Assistant(name: 'GPT 4o Mini', id: 'gpt-4o-mini', model: 'dify', tokenCost: 1)},
  ];
  String selectedAssistant = ""; // Default model selection

  late Assistant selectedAssistantDetails;

  Future<void> loadChat() async {
    // Load chat data if needed
    messages = await chat.getChatForMessage(conversationId) ?? [];
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    if (_messageController.text.isEmpty) return; // Check if the message is empty

    final content = _messageController.text.trim(); // Get the trimmed message content
    _messageController.clear(); // Clear the input field

    try {
      final response = await chat.sendMessage(content, selectedAssistantDetails, conversationId); // Send the message
      if (response != null) {
        setState(() {
          messages.add(ChatMessage(content: content, role: 'user')); // Add user message to chat
          messages.add(ChatMessage(content: response['message'], role: 'assistant')); // Add AI response to chat
        });
      }
    } catch (e) {
      print("Error sending message: $e"); // Handle error
    }
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      loadChat(); 
      if (assistants.isNotEmpty) {
        selectedAssistant = assistants.first['assistant']!.id; // Set default to the first assistant's id
        selectedAssistantDetails = assistants.first['assistant']!; // Set default assistant details
      }// Load chat data when the widget is initialized
    });
  }
  // Helper widget for AI bubble (left aligned)
  Widget _buildAIBubble(String text, String modelName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
            child: Text(
            text.trim(),
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }

  // Helper widget for user bubble (right aligned)
  Widget _buildUserBubble(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 255, 11),
            borderRadius: BorderRadius.circular(12),
          ),
            child: Text(
            text.trim(),
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Expanded scrollable area for main content
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (message.role == 'assistant') {
                    return _buildAIBubble(message.content, selectedAssistantDetails.name); // AI message bubble
                  } else {
                    return _buildUserBubble(message.content); // User message bubble
                  }
                },
              ),
            ),

            Container( //Sellect Assistant Dropdown
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: selectedAssistant,
                hint: const Text("Select Assistant"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                items: assistants.map((assistant) {
                  return DropdownMenuItem<String>(
                    value: assistant["assistant"]!.id,
                    child: Text(assistant["assistant"]!.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAssistant = value!;
                    selectedAssistantDetails = assistants.firstWhere((assistant) => assistant["assistant"]!.id == selectedAssistant)["assistant"]!;
                  });
                },
              ),
            ),

            // Fixed bottom bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF212121),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _layerLink,
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF2C003E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),

                          onChanged: (text) {
                            if (text.split(' ').last == '/') {
                              promptMenu.show(context: context, link: _layerLink, controller: _messageController);
                            }
                            else {
                              promptMenu.hide();
                            }
                          }
                        ),
                      ),
                    ) 
                  ),
                  _isLoading
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
