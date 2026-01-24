import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';

class UserService {
  static String get baseUrl => '${ApiConfig.baseUrl}/users';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<bool> followUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$userId/follow'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['isFollowing'];
    } else {
      throw Exception('Failed to follow user');
    }
  }

  Future<List<dynamic>> getFollowers(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/followers'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load followers');
    }
  }

  Future<List<dynamic>> getFollowing(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$userId/following'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load following list');
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search users');
    }
  }

  Future<void> deleteAccount() async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/me'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account');
    }
  }
}
