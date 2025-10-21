import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography styles following the design system
class AppTextStyles {
  // Body Text - Poppins 400, 16px
  static TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary2,
  );
  
  // Headings - Poppins 600-700, 22-48px
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static TextStyle heading4 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Digital Timer - Orbitron 700, 32-48px
  static TextStyle timerLarge = GoogleFonts.orbitron(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryCyan,
  );
  
  static TextStyle timerMedium = GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryCyan,
  );
  
  // Button Text - Poppins 700, 16-20px
  static TextStyle buttonLarge = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  
  static TextStyle buttonMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  
  // Subtitle Text
  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // Space Grotesk Alternative
  static TextStyle headingSpaceGrotesk = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  static TextStyle bodySpaceGrotesk = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary2,
  );
  
  AppTextStyles._(); // Private constructor to prevent instantiation
}
