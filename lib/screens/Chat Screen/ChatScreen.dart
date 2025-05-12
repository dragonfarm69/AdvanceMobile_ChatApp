import 'package:flutter/material.dart';
import '../../features/services/ai_chat.dart';
import '../../features/model/chat_message.dart';
import '../../features/model/assistant.dart';
import '../../Components/PromptMenu.dart';
import '../../features/services/chat_token.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId; // holds the passed conversation ID
  // Removed redundant final variable declaration
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  int remainingUsage = 0; // Placeholder for remaining usage
  PromptMenu promptMenu = PromptMenu(); // Instance of the PromptMenu class
  final LayerLink _layerLink = LayerLink();
  List<ChatMessage> messages = []; // Holds the chat messages
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  String get conversationId => widget.conversationId; // holds the passed conversation ID
  bool _isLoading = false;
  AiChat chat = AiChat(); // Instance of the Chat class// Instance of the PromptMenu class
  ChatToken chatToken = ChatToken(); // Instance of the ChatToken class

  List<Map<String, Assistant>> assistants = [
    {"assistant": Assistant(name: 'Claude 3 Haiku', id: 'claude-3-haiku-20240307', model: 'dify')},
    {"assistant": Assistant(name: 'Claude 35 Sonnet', id: 'claude-3-5-sonnet-20240620', model: 'dify')},
    {"assistant": Assistant(name: 'Gemini 1.5 Flash', id: 'gemini-1.5-flash-latest', model: 'dify')},
    {"assistant": Assistant(name: 'Gemini 1.5 Pro', id: 'gemini-1.5-pro-latest', model: 'dify')},
    {"assistant": Assistant(name: 'GPT 4o', id: 'gpt-4o', model: 'dify')},
    {"assistant": Assistant(name: 'GPT 4o Mini', id: 'gpt-4o-mini', model: 'dify')},
  ];
  String selectedAssistant = ""; // Default model selection

  late Assistant selectedAssistantDetails;

  Future<void> loadChat() async {
    // Load chat data if needed
    try {
    final allMessages = await chat.getChatForMessage(conversationId) ?? [];
      if (allMessages.isNotEmpty) {
        setState(() {
          messages = allMessages;
        });
      }

      await ChatToken.initializeTokens(); // Get remaining tokens
      int usage = await ChatToken.getTokens(); // Get remaining tokens
      setState(() {
        remainingUsage = usage; // Update the remaining usage
      });
    } on Exception catch (e) {
      print("Error: $e"); // Handle error
    }
  }

  Future<void> _simulateTyping(String fullText, int index) async {
    for (int i = 0; i <= fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 15));

        setState(() {
          if (index < messages.length) {
            // Update the typing message
            messages[index] = ChatMessage(content: fullText.substring(0, i), role: 'typing');
          } 
        });

        _scrollToBottom();
      }
    // Change the role to assistant when done

      setState(() {
        if (index < messages.length) {
          // Update the typing message
          messages[index] = ChatMessage(content: fullText, role: 'model');
        }
      });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() {
      _isLoading = true; // Show loading indicator
      messages.add(ChatMessage(content: _messageController.text, role: 'user')); // Add user message to chat
    });

    _scrollToBottom();
 // Check if the message is empty

    final content = _messageController.text.trim(); // Get the trimmed message content
    _messageController.clear(); // Clear the input field

    try {
      final history = messages.sublist(0, messages.length - 1);
      final response = await chat.sendMessage(content, selectedAssistantDetails, conversationId, history
      
      
      ); // Send the message
      if (response != null) {
        final typingMessage = ChatMessage(content: "", role: 'typing');
        setState(() {
          messages.add(typingMessage);
        });

        final typingIndex = messages.length - 1; // Get the index of the typing message
        await _simulateTyping(response['message'], typingIndex);
        final usage = response['remainingUsage'] ?? 0; // Get the token usage
        await ChatToken.setTokens(usage);
        setState(() {
          remainingUsage = usage; // Update remaining usage
              
          _isLoading = false; // Hide loading indicator
    
        });

      }
 // Simulate typing effect
    } catch (e) {
      print("Error sending message: $e"); // Handle error
      setState(() {
        _isLoading = false; // Hide loading indicator
        messages.removeLast(); // Remove the typing message
      });
    }

  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (assistants.isNotEmpty) {
      selectedAssistant = assistants.first['assistant']!.id; // Set default to the first assistant's id
      selectedAssistantDetails = assistants.first['assistant']!; // Set default assistant details
    };

    loadChat();
    _scrollToBottom();
  }
  // Helper widget for AI bubble (left aligned)
  Widget _buildAIBubble(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 0, 204, 255),
            borderRadius: BorderRadius.circular(12),
          ),
        child: MarkdownBody(
          data: text.trim(),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            p: const TextStyle(fontSize: 16, color: Colors.black),
          ),
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
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  if (message.role == 'user') {
                    return _buildUserBubble(message.content);
                  } else if (message.role == 'typing') {
                    return _buildAIBubble("${message.content}_"); // Optional: blinking cursor effect
                  } else {
                    return _buildAIBubble(message.content);
                  }
                },
              ),
            ),
            
            Container( //Sellect Assistant Dropdown
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: selectedAssistant,
                hint: const Text(
                  "Select Assistant",
                  style: TextStyle(color: Colors.white),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2C003E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                dropdownColor: const Color(0xFF2C003E),
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
                          decoration: InputDecoration(
                            hintText: "Message...",
                            hintStyle: const TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                          ),
                          style: const TextStyle(color: Colors.white),

                          onChanged: (text) {
                            if (text.endsWith('/')){
                              PromptMenu.show(context: context, link: _layerLink, controller: _messageController);
                            }

                            else {
                              PromptMenu.hide(); // Hide the prompt menu if the text doesn't end with '/'
                            }
                          },
                        ),
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

                        Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usage:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[300],
                    ),
                  ),
                  Text(
                    '$remainingUsage tokens',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
