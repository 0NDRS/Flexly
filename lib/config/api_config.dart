import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    // macOS/iOS simulator
    return 'http://127.0.0.1:3000/api';
  }
}
