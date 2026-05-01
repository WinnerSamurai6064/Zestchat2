// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class ZestColors {
  ZestColors._();

  // Primary accent — Lemon Green
  static const lemonGreen       = Color(0xFFCCF143);
  static const lemonGreenDim    = Color(0xFF9AB833);
  static const lemonGreenGlow   = Color(0xFFE8FF70);

  // Backgrounds — LED-Black / Dark Slate
  static const void_black       = Color(0xFF060608);
  static const slate900         = Color(0xFF0D0F14);
  static const slate800         = Color(0xFF13161E);
  static const slate700         = Color(0xFF1A1D28);
  static const slate600         = Color(0xFF22263A);
  static const slate500         = Color(0xFF2E3347);

  // Glass surfaces
  static const glassSurface     = Color(0x1AFFFFFF);
  static const glassBorder      = Color(0x26FFFFFF);
  static const glassHighlight   = Color(0x0DFFFFFF);

  // Semantic
  static const error            = Color(0xFFFF4757);
  static const online           = Color(0xFF2ED573);
  static const warning          = Color(0xFFFFB347);

  // Text
  static const textPrimary      = Color(0xFFF0F2FF);
  static const textSecondary    = Color(0xFF8890AB);
  static const textTertiary     = Color(0xFF4A5068);

  // Chat bubbles
  static const bubbleSent       = Color(0xFF1E2A14);
  static const bubbleSentBorder = Color(0xFF4A6B1A);
  static const bubbleReceived   = Color(0xFF161A24);
  static const bubbleReceivedBorder = Color(0xFF2A3050);
}

// ─── Glassmorphism Helper ─────────────────────────────────────────────────────
class GlassStyle {
  static BoxDecoration card({
    double opacity = 0.12,
    double borderOpacity = 0.18,
    double radius = 20,
    Color? tint,
  }) =>
      BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(borderOpacity),
          width: 1,
        ),
      );

  static BoxDecoration accentCard({double radius = 20}) => BoxDecoration(
        color: ZestColors.lemonGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: ZestColors.lemonGreen.withOpacity(0.25),
          width: 1,
        ),
      );
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ZestColors.void_black,
        colorScheme: const ColorScheme.dark(
          primary: ZestColors.lemonGreen,
          secondary: ZestColors.lemonGreenDim,
          surface: ZestColors.slate800,
          error: ZestColors.error,
          onPrimary: ZestColors.void_black,
          onSecondary: ZestColors.void_black,
          onSurface: ZestColors.textPrimary,
        ),
        fontFamily: 'Syne',
        textTheme: _textTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Syne',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ZestColors.textPrimary,
          ),
          iconTheme: IconThemeData(color: ZestColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ZestColors.slate700,
          hintStyle: const TextStyle(color: ZestColors.textTertiary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: ZestColors.glassBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: ZestColors.lemonGreen, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerColor: ZestColors.glassBorder,
        iconTheme: const IconThemeData(color: ZestColors.textSecondary),
      );

  static const TextTheme _textTheme = TextTheme(
    displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: ZestColors.textPrimary, letterSpacing: -1),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: ZestColors.textPrimary, letterSpacing: -0.5),
    titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ZestColors.textPrimary),
    titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ZestColors.textPrimary),
    bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ZestColors.textPrimary),
    bodyMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: ZestColors.textSecondary),
    labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ZestColors.textTertiary, letterSpacing: 0.5),
  );
}
