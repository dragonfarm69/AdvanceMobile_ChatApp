import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String initialMessage; // holds the passed message

  const ChatScreen({Key? key, required this.initialMessage}) : super(key: key);

  // Helper widget for AI bubble (left aligned)
  Widget _buildAIBubble(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 83, 177, 255),
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
                          const Text(
                            "New chat",
                            style: TextStyle(
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
                    _buildUserBubble(initialMessage),
                    // AI text bubble (aligned left)
                    _buildAIBubble("hello world"),
                    // Add more messages here if needed
                  ],
                ),
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
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
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
