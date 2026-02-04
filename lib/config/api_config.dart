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
      return 'http://10.0.2.2:3000/api';
    }
    // macOS/iOS - use Mac's local IP for physical devices
    return 'http://10.2.23.170:3000/api';
  }
}
