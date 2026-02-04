import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');

    if (override.isNotEmpty) {
      return override;
    }

    if (kReleaseMode) {
      return 'https://flexly-backend.onrender.com/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://10.2.23.170:3000/api';
  }
}
