import 'dart:convert';
import 'package:ai_chat_app/features/model/chat_message.dart';
import 'package:ai_chat_app/features/model/conversation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_chat_app/features/model/assistant.dart'; // Ensure this import exists
import 'package:ai_chat_app/features/services/chat_token.dart'; // Ensure this import exists

class AiChat {
    ChatToken chatToken = ChatToken();
    final String baseUrl = 'https://api.dev.jarvis.cx';
    Future<Map<String, dynamic>?> sendMessage(String content, Assistant assistant, String id) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? accessToken = prefs.getString('access_token');
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
        }

        List<ChatMessage> message = await getChatForMessage(id) ?? [];
        List<Map<String, dynamic>> messages = message.map((msg) => msg.toJson()).toList();

        Map<String, dynamic> assistantJson = {
            'id': assistant.id,
            'name': assistant.name,
            'model': assistant.model
        };

        for (var msg in messages) {
            msg['assistant'] = assistantJson;
        }

        final Map<String, String> headers = {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
        };

        var request = http.Request('POST', Uri.parse('$baseUrl/api/v1/chat'));
        request.body = json.encode({
            "content": content,
            "files": [],
            "metadata": {
                "conversation": {
                    "messages": message,
                }
            },
            "assistant": assistant.toJson(),
        });

        request.headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
            final data = await response.stream.bytesToString();

            final jsonResp = jsonDecode(data);

            final reply = jsonResp['message'];

            if (reply == null) {
                return null;
            }

            ChatToken.deductTokens(assistant.tokenCost);

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
            throw Exception('Access token is not available');
        }

        var headers = {
            'x-jarvis-guid': '',
            'Authorization': 'Bearer $accessToken',
        };

        var request = http.Request('GET', Uri.parse('$baseUrl/api/v1/ai-chat/conversations/$chatId/messages?assistantId=gpt-4o-mini&assistantModel=dify'));

        request.headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
            final data = await response.stream.bytesToString();
            final jsonResp = jsonDecode(data);
            final items = jsonResp['items'] as List<dynamic>;

            for (var item in items) {
    // User message
                messages.add(ChatMessage(
                    role: "user",
                    content: item['query'],
                ));

                // Assistant message
                messages.add(ChatMessage(
                    role: "assistant",
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

        var request = http.Request('GET', Uri.parse('/api/v1/ai-chat/conversations'));

        request.headers.addAll(headers);

        var response = await request.send();
        if (response.statusCode == 200) {
            final data = await response.stream.bytesToString();
            final jsonResp = jsonDecode(data);
            final items = jsonResp['items'] as List<Map<String, dynamic>>;

            for (var item in items){
                chats.add(Conversation(
                    id: item['id'],
                    title: item['title'],
                    createdAt: DateTime.fromMillisecondsSinceEpoch(item['createdAt'] * 1000),
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
        
        if (accessToken == null) {
            throw Exception('Access token is not available');
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

        var request = http.Request('POST', Uri.parse('$baseUrl/api/v1/chat'));
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

            if (reply == null) {
                return null;
            }

            ChatToken.deductTokens(assistant.tokenCost);

            return jsonResp;
        }

        else {
            print('Error: ${response.reasonPhrase}');
            return null;
        }
    }
}