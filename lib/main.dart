import 'package:flutter/material.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: const HomePage(),
    );
  }
}
