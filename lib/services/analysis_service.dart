import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalysisService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/analysis';
    }
    return 'http://localhost:3000/api/analysis';
  }

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
}
