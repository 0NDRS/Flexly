import 'package:shared_preferences/shared_preferences.dart';

class UnitUtils {
  static const String _unitKey = 'preferredUnits';
  static const String metric = 'Metric';
  static const String imperial = 'Imperial';

  static Future<String> getPreferredUnits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? metric;
  }

  static String formatHeight(num? heightCm, String units) {
    if (heightCm == null) return '-';
    final heightValue = heightCm.toDouble();

    if (units == imperial) {
      final totalInches = heightValue / 2.54;
      int feet = totalInches ~/ 12;
      int inches = (totalInches - feet * 12).round();
      if (inches == 12) {
        feet += 1;
        inches = 0;
      }
      return "$feet' ${inches.toStringAsFixed(0)}\"";
    }

    return '${heightValue.toStringAsFixed(0)} cm';
  }

  static String formatWeight(num? weightKg, String units) {
    if (weightKg == null) return '-';
    final weightValue = weightKg.toDouble();

    if (units == imperial) {
      final pounds = weightValue * 2.20462;
      return '${pounds.toStringAsFixed(1)} lb';
    }

    return '${weightValue.toStringAsFixed(1)} kg';
  }
}
