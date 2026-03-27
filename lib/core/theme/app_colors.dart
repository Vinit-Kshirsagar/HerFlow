import 'package:flutter/material.dart';

/// HerFlow Design System — Color Palette
class AppColors {
  AppColors._();

  // ─── Primary: Rose Mauve ───
  static const Color primary = Color(0xFFE8749A);
  static const Color primaryLight = Color(0xFFF2A8C8);
  static const Color primaryLighter = Color(0xFFF9D0E2);
  static const Color primaryDark = Color(0xFFC45882);
  static const Color primaryDarker = Color(0xFF9E3D63);

  // ─── Secondary: Lavender ───
  static const Color secondary = Color(0xFFC084FC);
  static const Color secondaryLight = Color(0xFFDEB8F8);
  static const Color secondaryLighter = Color(0xFFF0E4FF);
  static const Color secondaryDark = Color(0xFFA855F7);
  static const Color secondaryDarker = Color(0xFF7C3AED);

  // ─── Accent: Mint (Safe / Ovulation) ───
  static const Color accent = Color(0xFF6EE7B7);
  static const Color accentLight = Color(0xFFD1FAF0);
  static const Color accentDark = Color(0xFF10B981);
  static const Color accentDarker = Color(0xFF059669);

  // ─── Neutrals ───
  static const Color background = Color(0xFFFFF5F8);
  static const Color cardBg = Color(0xFFFDEEF4);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF2D0E4);
  static const Color textPrimary = Color(0xFF3D1F35);
  static const Color textSecondary = Color(0xFF7A5068);
  static const Color textMuted = Color(0xFFB89AAB);

  // ─── Phase Colors ───
  static const Color phasePeriod = Color(0xFFE8749A);      // Rose
  static const Color phaseFollicular = Color(0xFFC084FC);   // Lavender
  static const Color phaseOvulation = Color(0xFF6EE7B7);    // Mint
  static const Color phaseLuteal = Color(0xFFFBBF24);       // Amber

  // ─── Phase Colors Light (for backgrounds) ───
  static const Color phasePeriodLight = Color(0xFFFCE4EC);
  static const Color phaseFollicularLight = Color(0xFFF3E8FF);
  static const Color phaseOvulationLight = Color(0xFFD1FAE5);
  static const Color phaseLutealLight = Color(0xFFFEF3C7);

  // ─── Semantic Aliases ───
  static const Color periodRed = phasePeriod;
  static const Color ovulationGreen = phaseOvulation;

  // ─── Status ───
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Glassmorphism ───
  static const Color glassWhite = Color(0xBBFFFFFF);     // ~73% white
  static const Color glassBorder = Color(0x40FFFFFF);     // ~25% white
  static const Color glassShadow = Color(0x12000000);     // ~7% black

  // ─── Shimmer / Gradient Accents ───
  static const Color shimmerBase = Color(0xFFF2A8C8);     // primaryLight
  static const Color shimmerHighlight = Color(0xFFF9D0E2); // primaryLighter
  static const Color gradientStart = Color(0xFFE8749A);   // primary
  static const Color gradientEnd = Color(0xFFC084FC);     // secondary
}
