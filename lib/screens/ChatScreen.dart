import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "09:29",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.signal_cellular_alt, size: 16),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "27",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.battery_3_bar, size: 16),
                    ],
                  ),
                ],
              ),
            ),
            
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "New chat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit_square, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.ios_share, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Assistant profile card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF212121),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.chat_bubble_outline, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assistant",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "By ",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "@poe",
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    "228.6K followers",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "Bot info",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.person_add_alt, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF424242),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.ios_share, color: Colors.white),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    "General-purpose assistant. Write, code, ask for real-time information, create images, and more.",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Text(
                        "Variable ",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Icon(Icons.attach_money, color: Colors.grey, size: 16),
                      Text(
                        " per message · ",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "View details",
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF616161),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "OFFICIAL",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue chat button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFF212121),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Correct",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Continue your last chat with this bot",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Bottom suggestions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
TextField(
  decoration: InputDecoration(
    hintText: "Say something...",
    hintStyle: TextStyle(color: Colors.grey),
    border: InputBorder.none,
    prefixIcon: Icon(Icons.search, color: Colors.grey),
  ),
  style: TextStyle(color: Colors.grey),
),
                  const SizedBox(height: 16),
                  Text(
                    "Suggestions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSuggestionButton("Create a simple and responsive weather app using Flutter"),
                  const SizedBox(height: 12),
                  _buildSuggestionButton("Build a beautiful and interactive chat app with real-time messaging"
)
                ],
              ),
            ),
            
            // Bottom bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF212121),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.category, color: Colors.green),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Message",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Home indicator
            Container(
              width: 120,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.5),
              ),
              margin: const EdgeInsets.only(bottom: 8),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFF424242), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }
}