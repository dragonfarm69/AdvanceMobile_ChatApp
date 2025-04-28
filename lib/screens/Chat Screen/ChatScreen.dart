import 'package:flutter/material.dart';
import '../../features/services/ai_chat.dart';
import '../../features/model/chat_message.dart';
import '../../features/model/assistant.dart';

class ChatScreen extends StatefulWidget {
  final String? title;
  final String? content;
  final String? message; // holds the passed message Default value for selected assistant
  final String conversationId; // holds the passed conversation ID
  // Removed redundant final variable declaration
  const ChatScreen({super.key, this.title, this.content, this.message, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = []; // Holds the chat messages
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  String? get title => widget.title; // holds the passed title
  String? get content => widget.content;
  String? get message => widget.message; // holds the passed message
  String get conversationId => widget.conversationId; // holds the passed conversation ID
  bool _isLoading = false;
  AiChat chat = AiChat(); // Instance of the Chat class

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
        child: 
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
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
            text,
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar (content removed for brevity)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // Top bar content here...
                    ),
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/home');
                              },
                            ),

                            const SizedBox(width: 8),

                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            title != null ? title! : content != null ? content! : 'New Chat',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_square, color: Colors.grey),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.ios_share, color: Colors.grey),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User text bubble (aligned right)
                    ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        if (message.role == 'assistant') {
                          return _buildAIBubble(message.content, selectedAssistantDetails.name);
                        } else {
                          return _buildUserBubble(message.content);
                        }
                      },
                    ),
                    // Add more messages here if needed
                  ],
                ),
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
                  IconButton(
                  icon: const Icon(Icons.category, color: Colors.green),
                  onPressed: () {},
                  ),
                  Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  ),
                  IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.white),
                  onPressed: () {},
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
