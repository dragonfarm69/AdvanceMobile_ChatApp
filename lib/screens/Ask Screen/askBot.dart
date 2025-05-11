import 'dart:async';
import 'package:flutter/material.dart';
import '../../Classes/chatMessage.dart';
import '../../features/services/botAsk.dart';

class AskScreen extends StatefulWidget {
  final String botId;
  final String apiBaseUrl;
  final String? botName;

  const AskScreen({
    Key? key,
    required this.botId,
    required this.apiBaseUrl,
    this.botName,
  }) : super(key: key);

  @override
  _AskScreenState createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final BotApiService _apiService;
  StreamSubscription<String>? _subscription;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _apiService = BotApiService(baseUrl: widget.apiBaseUrl);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // First add user message
    setState(() {
      _messages.add(ChatMessage(content: text, isUser: true));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    final stream = _apiService.ask(widget.botId, text);

    // Then add bot message placeholder
    setState(() {
      _messages.add(ChatMessage(content: '', isUser: false));
    });
    int messageIndex = _messages.length - 1; // This is now the index of the bot message
    _scrollToBottom();

    // Now update the bot message with streaming content
    _subscription = stream.listen(
      (chunk) {
        setState(() {
          final prev = _messages[messageIndex].content;
          _messages[messageIndex] = ChatMessage(
            content: prev + chunk,
            isUser: false,
          );
        });
        _scrollToBottom();
      },
      onError: (error) {
        setState(() {
          _isTyping = false;
          _messages[messageIndex] = ChatMessage(
            content: 'Sorry, I encountered an error: ${error.toString()}',
            isUser: false,
          );
        });
        _scrollToBottom();
      },
      onDone: () {
        setState(() {
          _isTyping = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo[400],
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.botName ?? "Bot",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_isTyping)
                  const Text(
                    "typing...",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), // Slightly lighter than main background
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messages.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Send a message to start chatting",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _buildMessageItem(msg, index);
                      },
                    ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E), // Slightly lighter than main background
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -1),
                  blurRadius: 3,
                  color: Color(0xFF0A0A0A),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(
                        0xFF2A2A2A,
                      ), // Input field background
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo[400],
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, int index) {
    final bool isFirstMessageFromUser =
        index == 0 || _messages[index - 1].isUser != message.isUser;
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isFirstMessageFromUser)
            Padding(
              padding: EdgeInsets.only(
                bottom: 4,
                left: isUser ? 0 : 12,
                right: isUser ? 12 : 0,
              ),
              child: Text(
                isUser ? 'You' : widget.botName ?? 'Bot',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser && isFirstMessageFromUser)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.indigo[400],
                  child: const Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if (!isUser && !isFirstMessageFromUser) const SizedBox(width: 32),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Colors.indigo[400] // User message
                            : const Color(0xFF2A2A2A), // Bot message
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.grey[300],
                    ),
                  ),
                ),
              ),
              if (isUser && isFirstMessageFromUser)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if (isUser && !isFirstMessageFromUser) const SizedBox(width: 32),
            ],
          ),
        ],
      ),
    );
  }
}
