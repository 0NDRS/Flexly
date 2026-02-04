import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';

class TrainingService {
  static String get baseUrl => '${ApiConfig.baseUrl}/training';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> generateTrainingPlan() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/generate'),
      headers: headers,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to generate training plan');
    }
  }

  Future<Map<String, dynamic>> getTrainingPlans(
      {int page = 1, int limit = 10}) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl?page=$page&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load training plans');
    }
  }

  Future<Map<String, dynamic>> getTrainingPlan(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load training plan');
    }
  }

  Future<void> deleteTrainingPlan(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete training plan');
    }
  }
}
