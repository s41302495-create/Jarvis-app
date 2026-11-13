import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OmniRouteService {
  static const _storage = FlutterSecureStorage();
  static const _urlKey = 'omniroute_base_url';
  static const _apiKeyKey = 'omniroute_api_key';
  static const _modelKey = 'omniroute_model';

  String baseUrl = '';
  String apiKey = '';
  String model = 'Ai';

  Future<void> reload() async {
    baseUrl = await _storage.read(key: _urlKey) ?? baseUrl;
    apiKey = await _storage.read(key: _apiKeyKey) ?? '';
    model = await _storage.read(key: _modelKey) ?? model;
  }

  Future<void> save({required String baseUrl, required String apiKey, required String model}) async {
    if (baseUrl.isEmpty || model.isEmpty) {
      throw ArgumentError('Base URL and model are required.');
    }
    this.baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    this.apiKey = apiKey;
    this.model = model;
    await _storage.write(key: _urlKey, value: this.baseUrl);
    await _storage.write(key: _apiKeyKey, value: apiKey);
    await _storage.write(key: _modelKey, value: model);
  }

  Future<String> chat(List<Map<String, String>> messages) async {
    await reload();
    final uri = Uri.parse('$baseUrl/chat/completions');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (apiKey.isNotEmpty) headers['Authorization'] = 'Bearer $apiKey';

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'stream': false,
      }),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}: ${_short(response.body)}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('The server returned no choices.');
    }
    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content'];
    if (content is String && content.isNotEmpty) return content;
    throw Exception('The server response did not contain text content.');
  }

  String _short(String value) => value.length > 500 ? '${value.substring(0, 500)}…' : value;
}
