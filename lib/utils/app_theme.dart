import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand palette - colorful & playful
  static const coral = Color(0xFFFF6B6B);
  static const sunflower = Color(0xFFFFD93D);
  static const mint = Color(0xFF6BCB77);
  static const sky = Color(0xFF4D96FF);
  static const lavender = Color(0xFFB983FF);
  static const peach = Color(0xFFFFB347);
  static const cream = Color(0xFFFFFBF0);
  static const charcoal = Color(0xFF2D2D2D);
  static const softGrey = Color(0xFFF5F3EE);
  static const cardWhite = Color(0xFFFFFFFF);

  // Gradient combos for person cards
  static const cardGradients = [
    [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    [Color(0xFF4D96FF), Color(0xFF6CB4FF)],
    [Color(0xFF6BCB77), Color(0xFF4CAF7D)],
    [Color(0xFFB983FF), Color(0xFF8B5CF6)],
    [Color(0xFFFFD93D), Color(0xFFFFB347)],
    [Color(0xFFFF6BAA), Color(0xFFFF8E70)],
  ];

  static List<Color> cardGradientFor(int index) {
    final g = cardGradients[index % cardGradients.length];
    return [g[0], g[1]];
  }

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
          surface: cream,
        ),
        scaffoldBackgroundColor: cream,
        textTheme: GoogleFonts.nunitoTextTheme(
          const TextTheme(
            displayLarge: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w800, color: charcoal),
            displayMedium: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w700, color: charcoal),
            headlineMedium: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: charcoal),
            titleLarge: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: charcoal),
            titleMedium: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: charcoal),
            bodyLarge: TextStyle(fontSize: 16, color: charcoal),
            bodyMedium: TextStyle(fontSize: 14, color: charcoal),
            labelLarge: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: charcoal),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: coral,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
            textStyle: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: coral, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: cardWhite,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: cream,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: charcoal,
          ),
          iconTheme: const IconThemeData(color: charcoal),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          elevation: 4,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: softGrey,
          selectedColor: coral.withOpacity(0.15),
          labelStyle:
              GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
      );
}
