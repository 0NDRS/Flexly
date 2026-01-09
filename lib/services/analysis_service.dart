import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/config/api_config.dart';

class AnalysisService {
  static String get baseUrl => '${ApiConfig.baseUrl}/analysis';

  Future<Map<String, dynamic>> uploadAndAnalyze(List<File> images) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // Add headers (Auth token)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add images
      for (var image in images) {
        final mimeTypeData =
            lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');

        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: mimeTypeData != null
              ? MediaType(mimeTypeData[0], mimeTypeData[1])
              : null,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to analyze images: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading images: $e');
    }
  }

  Future<List<dynamic>> getAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load analyses');
      }
    } catch (e) {
      throw Exception('Error fetching analyses: $e');
    }
  }

  Future<List<dynamic>> getAnalysesByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load user analyses');
      }
    } catch (e) {
      throw Exception('Error fetching user analyses: $e');
    }
  }

  static int calculateStreak(List<dynamic> analyses) {
    if (analyses.isEmpty) return 0;

    final dates = analyses
        .map((a) => DateTime.parse(a['createdAt']))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) return 0;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedYesterday =
        normalizedToday.subtract(const Duration(days: 1));

    if (dates.first != normalizedToday && dates.first != normalizedYesterday) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = dates.first;

    for (var date in dates) {
      if (date == expectedDate) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
