import 'package:flutter/material.dart';

class AppPalette {
  final Color primary;
  final Color white;
  final Color grayLight;
  final Color grayDark;
  final Color gray;
  final Color background;
  final Color fireOrange;
  final Color fireBackground;
  final Color waterBlue;
  final Color waterBackground;
  final Color tooltipBackground;
  final Color barInactive;

  const AppPalette({
    required this.primary,
    required this.white,
    required this.grayLight,
    required this.grayDark,
    required this.gray,
    required this.background,
    required this.fireOrange,
    required this.fireBackground,
    required this.waterBlue,
    required this.waterBackground,
    required this.tooltipBackground,
    required this.barInactive,
  });

  const AppPalette.dark()
      : primary = const Color(0xFFEE0003),
        white = const Color(0xFFFFFFFF),
        grayLight = const Color(0xFF5F5F5F),
        grayDark = const Color(0xFF191919),
        gray = const Color(0xFF2E2E2E),
        background = const Color(0xFF080808),
        fireOrange = const Color(0xFFFF9500),
        fireBackground = const Color(0xFF332B20),
        waterBlue = const Color(0xFF30A3D1),
        waterBackground = const Color(0xFF1C252E),
        tooltipBackground = const Color(0xFF8B0000),
        barInactive = const Color(0xFF7A3E3E);

  const AppPalette.light()
      : primary = const Color(0xFFEE0003),
        white = const Color(0xFF0A0A0A),
        grayLight = const Color(0xFF8A8A8A),
        grayDark = const Color(0xFFF2F2F2),
        gray = const Color(0xFFE0E0E0),
        background = const Color(0xFFF8F8F8),
        fireOrange = const Color(0xFFE65100),
        fireBackground = const Color(0xFFFFE6CC),
        waterBlue = const Color(0xFF1E88E5),
        waterBackground = const Color(0xFFE3F2FD),
        tooltipBackground = const Color(0xFFB71C1C),
        barInactive = const Color(0xFFBDBDBD);
}

class AppColors {
  static AppPalette _current = const AppPalette.dark();
  static final ValueNotifier<AppPalette> notifier =
      ValueNotifier<AppPalette>(_current);

  static void setPalette(AppPalette palette) {
    _current = palette;
    notifier.value = palette;
  }

  static AppPalette get palette => _current;

  static Color get primary => _current.primary;
  static Color get white => _current.white;
  static Color get grayLight => _current.grayLight;
  static Color get grayDark => _current.grayDark;
  static Color get gray => _current.gray;
  static Color get backgroundDark => _current.background;
  static Color get fireOrange => _current.fireOrange;
  static Color get fireBackground => _current.fireBackground;
  static Color get waterBlue => _current.waterBlue;
  static Color get waterBackground => _current.waterBackground;
  static Color get tooltipBackground => _current.tooltipBackground;
  static Color get barInactive => _current.barInactive;
}
