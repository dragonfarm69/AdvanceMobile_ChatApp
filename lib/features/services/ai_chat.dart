import 'dart:convert';
import 'package:ai_chat_app/features/model/chat_message.dart';
import 'package:ai_chat_app/features/model/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_chat_app/features/model/assistant.dart'; // Ensure this import exists
import 'package:ai_chat_app/features/services/chat_token.dart'; // Ensure this import exists

class AiChat {
    final String baseUrl = 'https://api.dev.jarvis.cx';
    Future<Map<String, dynamic>?> sendMessage(String content, Assistant assistant, String id, List<ChatMessage> history) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        final int initialRemainingUsage = await ChatToken.getTokens();
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        if (initialRemainingUsage <= 0) {
            throw Exception('No tokens available');
        }

        List<Map<String, dynamic>> messages = history.map((msg) => msg.toJson()).toList();

        for (var msg in messages) {
            msg['assistant'] = assistant.toJson();
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
        };

        final response = await http.post(
            Uri.parse('$baseUrl/api/v1/ai-chat/messages'),
            headers: headers,
            body: json.encode({
            "content": content,
            "files": [],
            "metadata": {
                "conversation": {
                "id": id,
                "messages": messages,
                }
            },
            "assistant": assistant.toJson(),
            }),
        );
        if (response.statusCode == 200) {
            final jsonResp = jsonDecode(response.body);

            final reply = jsonResp['message'];
            final int remainingUsage = jsonResp['remainingUsage'] as int;

            if (reply == null) {
                return null;
            }

            await ChatToken.setTokens(remainingUsage);

            return jsonResp;
        } else {
            print('Error: ${response.reasonPhrase}');
            return null;
        }
    }

    Future<List<ChatMessage>?> getChatForMessage(String chatId) async {
        List<ChatMessage> messages = [];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        if (accessToken == null) {
            print('Access token is not available');
            return null;
        }

        var headers = {
            'x-jarvis-guid': '',
            'Authorization': 'Bearer $accessToken',
        };

        final response = await http.get(
            Uri.parse('$baseUrl/api/v1/ai-chat/conversations/$chatId/messages?assistantId=gpt-4o-mini&assistantModel=dify'),
            headers: headers,
        );
        
        if (response.statusCode == 200) {
            final jsonResp = jsonDecode(response.body);
            final items = jsonResp['items'] as List<dynamic>;

            for (var item in items) {
    // User message
                messages.add(ChatMessage(
                    role: "user",
                    content: item['query'],
                ));

                // Assistant message
                messages.add(ChatMessage(
                    role: "model",
                    content: item['answer'],
                ));
            }
            return messages;
        } else {
            print('Error: ${response.reasonPhrase}');
            return null;
        }
    }

    Future<List<Conversation>?> getAllChats() async {
        List<Conversation> chats = [];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        var headers = {
            'x-jarvis-guid': '',
            'Authorization': 'Bearer $accessToken',
        };

        final response = await http.get(
            Uri.parse('$baseUrl/api/v1/ai-chat/conversations?assistantModel=dify'),
            headers: headers,
        );

        if (response.statusCode == 200) {
            final jsonResp = jsonDecode(response.body);
            final items = (jsonResp['items'] as List).map((item) => item as Map<String, dynamic>).toList();

            for (var item in items){
                chats.add(Conversation(
                    id: item['id'],
                    title: item['title'],
                    createdAt: DateTime.parse(item['createdAt']),
                ));
            }

            return chats;
        } else {
            print('Error: ${response.reasonPhrase}');
            return null;
        }
    }

    Future<Map<String, dynamic>?> newChat(String content, Assistant assistant) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        final int initialRemainingUsage = await ChatToken.getTokens();
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        if (initialRemainingUsage <= 0) {
            throw Exception('No tokens available');
        }

        Map<String, dynamic> assistantJson = {
            'id': assistant.id,
            'name': assistant.name,
            'model': assistant.model
        };


        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
        };

        var request = http.Request('POST', Uri.parse('$baseUrl/api/v1/ai-chat/messages'));
        request.body = json.encode({
            "content": content,
            "files": [],
            "metadata": {
                "conversation": {
                    "messages": [],
                }
            },

            "assistant": assistantJson,
        });

        request.headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
            final data = await response.stream.bytesToString();

            final jsonResp = jsonDecode(data);

            final reply = jsonResp['message'];
            final int remainingUsage = jsonResp['remainingUsage'] as int;

            if (reply == null) {
                return null;
            }

            await ChatToken.setTokens(remainingUsage);

            return jsonResp;
        }

        else {
            print('Error: ${response.reasonPhrase}');
            return null;
        }
    }
}