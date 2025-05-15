import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_store.dart';

class BotApiService {
  final String baseUrl;
  final http.Client _client;

  BotApiService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  // Future<Map<String, String>> _getHeaders() async {
  //   final tokens = await TokenStore.getTokens();
  //   if (tokens == null || tokens['access_token'] == null) {
  //     throw Exception('No access token available');
  //   }

  //   return {
  //     'x-jarvis-guid': '',
  //     'Authorization': 'Bearer ${tokens['access_token']}',
  //     'Content-Type': 'application/json',
  //   };
  // }

  Future<String> _getToken() async {
    final tokens = await TokenStore.getTokens();
    if (tokens == null || tokens['access_token'] == null) {
      throw Exception('No access token available');
    }
    return tokens['access_token']!;
  }

  /// Streams partial bot replies for a given question via SSE
  Stream<String> ask(
    String botId,
    String question,
  ) async* {
    final uri = Uri.parse(
      '$baseUrl/kb-core/v1/ai-assistant/$botId/ask',
    );
    String token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'text/event-stream',
    };

    final request = http.Request('POST', uri)
      ..headers.addAll(headers)
      ..body = jsonEncode({'message': question});

    final streamed = await _client.send(request);
    // Decode and parse SSE events
    final lines = utf8.decoder
        .bind(streamed.stream)
        .transform(const LineSplitter());

    // String buffer = '';
    await for (final raw in lines) {
      if (raw.startsWith('data:')) {
        final data = raw.substring(5).trim();
        if (data.isEmpty || data == "[DONE]") continue;
        try {
          final Map<String, dynamic> obj = jsonDecode(data);
          if (obj.containsKey('content')) {
            yield obj['content'] as String;
          }
        } catch (_) {
          // Not JSON or parsing failed
          yield data;
        }
      }
      // ignore other lines (e.g., event: message)
    }
  }
}