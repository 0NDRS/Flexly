import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');

    // If a build-time override is provided, prefer it so we can target remote environments.
    if (override.isNotEmpty) {
      return override;
    }

    // Use production URL in release mode
    if (kReleaseMode) {
      return 'https://flexly-backend.onrender.com/api';
    }

    if (Platform.isAndroid) {
      return 'http://127.0.0.1:3000/api';
    }
    // macOS/iOS simulator - when testing: http://127.0.0.1:3000/api
    return 'http://127.0.0.1:3000/api';
  }
}
