import 'package:ai_chat_app/features/model/assistant.dart';
import 'package:ai_chat_app/features/model/conversation.dart';
import 'package:flutter/material.dart';
import '../../Components/ChatHistoryItem.dart';
import '../../Components/botCard.dart';
import '../../Components/MenuSideBar.dart';
import '../../features/services/ai_chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  final AiChat chatService = AiChat(); // Initialize your chat service

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
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  // Sample chat history data
  List<Conversation> chatHistory = [];

  Future<void> _loadChat() async {
    // Load chat data if needed
    chatHistory = await chatService.getAllChats() ?? [];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _isSearching = false;
        });
      }
    });
    if (assistants.isNotEmpty) {
      selectedAssistant = assistants.first['assistant']!.id; // Set default to the first assistant's id
      selectedAssistantDetails = assistants.first['assistant']!; // Set default to the first assistant's details
    }
    setState(() {
      _loadChat();
    });
  }

  Future<void> _sendMessage() async {
    setState(() {
      _isLoading = true;
    });

    final text = _messageController.text.trim();

    if (text.isEmpty) {    
      setState(() {
        _isLoading = false;
      });
      return; // Ignore empty messagesreturn
    } // Ignore empty messages

    final result = await chatService.newChat(text, selectedAssistantDetails);

    if (result != null) {
      // Handle successful response, e.g., update UI or show a message
      final message = result['messages'];
      final conversationId = result['conversationId'];

      await Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'content': text,
          'message': message,
          'conversationId': conversationId,
        },
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      // Handle error, e.g., show a snackbar or alert dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      drawer: menuSideBar(context),
      body: SafeArea(
        bottom: false, // Let the input field extend to the bottom for more space
        child: Column(
          children: [
            // Top bar with improved layout
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: 'Menu',
                    ),
                  ),
                  
                  // Search field with improved animation
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => 
                        FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        ),
                      child: _isSearching
                          ? Container(
                              key: const ValueKey('searchField'),
                              height: 44,
                              child: TextField(
                                focusNode: _searchFocusNode,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Search chats...",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  fillColor: const Color(0xFF212121),
                                  filled: true,
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        _isSearching = false;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey('empty'),
                            ),
                    ),
                  ),
                  
                  // Search icon button
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                      _searchFocusNode.requestFocus();
                    },
                    tooltip: 'Search',
                  ),
                ],
              ),
            ),

            // Bot cards carousel with overflow protection
            Container(
              height: 140, // Fixed height to prevent vertical overflow
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  buildBotCard(
                    icon: Icons.smart_toy,
                    name: "General AI",
                    description: "Chat with a general purpose assistant",
                  ),
                  const SizedBox(width: 12),
                  buildBotCard(
                    icon: Icons.code,
                    name: "Code Assistant",
                    description: "Help with programming tasks",
                  ),
                  const SizedBox(width: 12),
                  buildBotCard(
                    icon: Icons.school,
                    name: "Learning Bot",
                    description: "Your personal study companion",
                  ),
                  const SizedBox(width: 12),
                  buildBotCard(
                    icon: Icons.image,
                    name: "Image Creator",
                    description: "Generate creative visuals",
                  ),
                ],
              ),
            ),

            // Chat history section label
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Chats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[300],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),

            // Chat History list
            Expanded(
              child: chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chat history yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: chatHistory.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final chat = chatHistory[index];
                      return chatHistoryItem(
                        conversationId: chat.id,
                        title: chat.title,
                        date: "${chat.createdAt.year}-${chat.createdAt.month.toString().padLeft(2, '0')}-${chat.createdAt.day.toString().padLeft(2, '0')}",
                        context: context,
                      );
                    },
                  ),
            ),

            Container( // Assistant selection dropdown
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
                    value: assistant["assistant"]?.id,
                    child: Text(assistant["assistant"]!.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAssistant = value!;
                    selectedAssistantDetails = assistants.firstWhere((assistant) => assistant["assistant"]!.id == value)["assistant"]!;
                  });
                },
              ),
            ),

            // Input field with improved layout
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                    // Select model

                    Expanded( // Enter chat
                      child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic, color: Colors.grey),
                          onPressed: () {},
                          tooltip: 'Voice input',
                        ),
                        ),
                      ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      ),
                      child: _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                          ),
                        )
                        : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _isLoading ? null : _sendMessage,
                          tooltip: 'Send message',
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}