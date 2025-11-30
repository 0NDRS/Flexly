import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.1,
        color: AppColors.white,
      );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.1,
        color: AppColors.white,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: AppColors.white,
      );

  static TextStyle get button1 => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        height: 1.1,
        color: AppColors.white,
      );

  static TextStyle get button2 => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: AppColors.white,
      );

  static TextStyle get caption1 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.white,
      );

  static TextStyle get caption2 => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.white,
      );

  static TextStyle get body1 => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.white,
      );

  static TextStyle get body2 => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.3,
        color: AppColors.white,
      );

  static TextStyle get small => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w300,
        height: 1.3,
        color: AppColors.white,
      );
}
