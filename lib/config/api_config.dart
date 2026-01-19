import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');

    // If a build-time override is provided, prefer it so we can target remote environments.
    if (override.isNotEmpty) {
      return override;
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    // macOS/iOS simulator
    return 'http://127.0.0.1:3000/api';
  }
}
