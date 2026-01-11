import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';

class CommentService {
  static String get baseUrl => '${ApiConfig.baseUrl}/analysis';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getComments(String analysisId) async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$baseUrl/$analysisId/comments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Map<String, dynamic>> addComment(
      String analysisId, String text) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$baseUrl/$analysisId/comments'),
      headers: headers,
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> deleteComment(String commentId) async {
    final headers = await _headers();
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }
}
