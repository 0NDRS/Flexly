import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';
import 'package:flexly/models/notification_model.dart';

class NotificationService {
  static String get baseUrl => '${ApiConfig.baseUrl}/notifications';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<NotificationModel>> getNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markRead() async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/read'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notifications as read');
    }
    // We don't really need to return anything here if it succeeds
  }
}
