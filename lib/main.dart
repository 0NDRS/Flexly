import 'package:flutter/material.dart';
import 'package:flexly/pages/splash_page.dart';
import 'package:flexly/pages/login_page.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StartTarget { loading, splash, login, home }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the default dark palette; theme switching has been removed.
  AppColors.setPalette(const AppPalette.dark());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppColors.notifier,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flexly',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(AppColors.palette),
          home: const AppStartPage(),
        );
      },
    );
  }

  ThemeData _buildTheme(AppPalette palette) {
    final isDark = palette.background.computeLuminance() < 0.5;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      colorScheme: (isDark
              ? ColorScheme.dark(
                  primary: palette.primary, surface: palette.background)
              : ColorScheme.light(
                  primary: palette.primary, surface: palette.background))
          .copyWith(onSurface: palette.white),
      textTheme: base.textTheme
          .apply(bodyColor: palette.white, displayColor: palette.white)
          .copyWith(
            headlineLarge: AppTextStyles.h1,
            headlineMedium: AppTextStyles.h2,
            bodyLarge: AppTextStyles.body1,
            bodyMedium: AppTextStyles.body2,
            labelLarge: AppTextStyles.button2,
            labelMedium: AppTextStyles.caption1,
            labelSmall: AppTextStyles.caption2,
          ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.grayDark.withValues(alpha: 0.95),
        contentTextStyle: AppTextStyles.body2.copyWith(color: palette.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
      ),
    );
  }
}

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  final _authService = AuthService();
  StartTarget _target = StartTarget.loading;

  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // If token exists, try to fetch profile to auto-login
    final token = prefs.getString('token');
    if (token != null) {
      final profile = await _authService.getProfile();
      if (profile != null) {
        if (mounted) {
          setState(() => _target = StartTarget.home);
        }
        return;
      }
    }

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      if (mounted) setState(() => _target = StartTarget.splash);
    } else {
      if (mounted) setState(() => _target = StartTarget.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_target) {
      case StartTarget.loading:
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: const Center(child: CircularProgressIndicator()),
        );
      case StartTarget.splash:
        return const SplashPage();
      case StartTarget.login:
        return const LoginPage();
      case StartTarget.home:
        return const HomePage();
    }
  }
}
