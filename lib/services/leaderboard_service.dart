import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';

class LeaderboardService {
  static String get baseUrl => '${ApiConfig.baseUrl}/users/leaderboard';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getLeaderboard({
    String category = 'Overall',
    String gender = 'All',
    String weightClass = 'All',
  }) async {
    final headers = await _getHeaders();

    // Construct Query String
    final queryParams = <String, String>{};
    if (category != 'Overall') queryParams['category'] = category;
    if (gender != 'All') queryParams['gender'] = gender;
    if (weightClass != 'All') queryParams['weightClass'] = weightClass;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}
