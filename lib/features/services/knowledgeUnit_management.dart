// import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../Classes/knowledgeUnit.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../Classes/FileResponse.dart';
import './token_store.dart';

class KnowledgeUnitManager {
  static const String baseUrl = 'https://knowledge-api.dev.jarvis.cx';

  // Helper method to get authorization headers with token
  Future<Map<String, String>> _getHeaders() async {
    final tokens = await TokenStore.getTokens();
    if (tokens == null || tokens['access_token'] == null) {
      throw Exception('No access token available');
    }
    
    return {
      'x-jarvis-guid': '',
      'Authorization': 'Bearer ${tokens['access_token']}',
      'Content-Type': 'application/json',
    };
  }

  Future<void> importKnowledgeUnit() async {}

  Future<List<KnowledgeUnit>> getKnowledgeUnit(String knowledgeId) async {
    final uri = Uri.parse(
      '$baseUrl/kb-core/v1/knowledge/$knowledgeId/datasources'
      '?order=DESC&order_field=createdAt&limit=20',
    );
    print("Fetching units from: $uri");

    final headers = await _getHeaders();
    final request = http.Request('GET', uri)..headers.addAll(headers);
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to load units: ${response.reasonPhrase}');
    }

    // 1) Read the raw string
    final responseBody = await response.stream.bytesToString();
    print("RAW RESPONSE: $responseBody");

    // 2) Decode JSON once
    final decoded = json.decode(responseBody);

    // 3) Extract the list, whether it's raw or wrapped in { data: [...] }
    List<dynamic> jsonData;
    if (decoded is List) {
      jsonData = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      jsonData = decoded['data'] as List<dynamic>;
    } else {
      throw Exception('Unexpected JSON format: $decoded');
    }

    // 4) Map JSON data to KnowledgeUnit objects
    List<KnowledgeUnit> units =
        jsonData.map((item) => KnowledgeUnit.fromJson(item)).toList();

    return units;
  }

  Future<void> addKnowledgeUnit(
    String knowledgeId,
    FileResponse fileResponse,
  ) async {
    print("IWAS CALLED 3");
    // Validate input
    if (fileResponse.files == null || fileResponse.files!.isEmpty) {
      throw Exception('No valid files to add to knowledge unit');
    }

    // Prepare request headers
    var headers = await _getHeaders();

    // Create request URL
    var request = http.Request(
      'POST',
      Uri.parse('$baseUrl/kb-core/v1/knowledge/$knowledgeId/datasources'),
    );

    // Add headers
    request.headers.addAll(headers);

    // Create datasources list based on file response
    List<Map<String, dynamic>> datasources = [];

    for (var file in fileResponse.files!) {
      datasources.add({
        'type': 'local_file',
        'name': file.name,
        'credentials': {'file': file.id},
      });
    }

    // Create the request body with the expected structure
    final Map<String, dynamic> requestBody = {'datasources': datasources};

    // Set request body
    request.body = json.encode(requestBody);

    // Send the request
    print('Sending request with body: ${request.body}');
    http.StreamedResponse response = await request.send();

    // Process response
    final String responseBody = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $responseBody');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to add knowledge unit: ${response.statusCode} ${response.reasonPhrase}\nResponse: $responseBody',
      );
    }

    print('Knowledge unit added successfully');
  }

  Future<FileResponse> uploadLocalFile(
    FilePickerResult result,
    String knowledgeId,
  ) async {
    // Get tokens for authentication
    final tokens = await TokenStore.getTokens();
    if (tokens == null || tokens['access_token'] == null) {
      throw Exception('No access token available');
    }
    
    // Prepare multipart request
    final uri = Uri.parse(
      'https://knowledge-api.dev.jarvis.cx/kb-core/v1/knowledge/files',
    );
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer ${tokens['access_token']}',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.7',
    });

    // Add the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'files',
        result.files.single.path!,
        filename: result.files.single.name,
        contentType: MediaType.parse(
          lookupMimeType(result.files.single.path!) ??
              'application/octet-stream',
        ),
      ),
    );

    // Send the request
    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    // Log response info
    print('Response status code: ${resp.statusCode}');
    print('Response body: ${resp.body}');

    // Process response
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      // import the file to knowlodge
      await addKnowledgeUnit(
        knowledgeId,
        FileResponse.fromJson(json.decode(resp.body)),
      );

      print('Upload successful!');
      final responseData = json.decode(resp.body);
      return FileResponse.fromJson(responseData);
    } else {
      throw Exception(
        'Upload failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
      );
    }
  }

  Future<void> toggleUnit(String knowledgeId, String unitId, bool status) async {
    //request api
    var headers = await _getHeaders();
    var request = http.Request(
      'PATCH',
      Uri.parse('$baseUrl/kb-core/v1/knowledge/$knowledgeId/datasources/$unitId'),
    );

    request.body = json.encode({
      "status": status,
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}