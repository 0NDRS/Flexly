import 'package:flutter/material.dart';
import 'package:flexly/pages/splash_page.dart';
import 'package:flexly/pages/login_page.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.backgroundDark,
          onSurface: AppColors.white,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: AppColors.white,
                displayColor: AppColors.white,
              ),
        ).copyWith(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          bodyLarge: AppTextStyles.body1,
          bodyMedium: AppTextStyles.body2,
          labelLarge: AppTextStyles.button2,
          labelMedium: AppTextStyles.caption1,
          labelSmall: AppTextStyles.caption2,
        ),
      ),
      home: const AppStartPage(),
    );
  }
}

class AppStartPage extends StatefulWidget {
  const AppStartPage({super.key});

  @override
  State<AppStartPage> createState() => _AppStartPageState();
}

class _AppStartPageState extends State<AppStartPage> {
  late Future<bool> _isFirstTime;

  @override
  void initState() {
    super.initState();
    _isFirstTime = _checkIfFirstTime();
  }

  Future<bool> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    
    if (isFirstTime) {
      // Mark as not first time anymore
      await prefs.setBool('isFirstTime', false);
    }
    
    return isFirstTime;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isFirstTime,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // First time - show splash screen (which leads to registration)
          return const SplashPage();
        } else {
          // Not first time - show login page (for returning users)
          return const LoginPage();
        }
      },
    );
  }
}
