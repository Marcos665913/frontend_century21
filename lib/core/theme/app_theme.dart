// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = _buildLightTheme();

  static ThemeData _buildLightTheme() {
    final ThemeData base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),

      colorScheme: base.colorScheme.copyWith(
        primary: Colors.black,
        secondary: const Color(0xFFFFC000),      
        surface: Colors.white,
        onPrimary: Colors.white,                 
        onSecondary: Colors.black,
        onSurface: Colors.black87,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4.0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: base.cardTheme.copyWith(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.white,
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
          surfaceTintColor: WidgetStateProperty.all<Color>(Colors.white),
          elevation: WidgetStateProperty.all<double>(3),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),

      // --- SECCIÓN AÑADIDA PARA BOTONES FLOTANTES ---
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFFFBC02D), // Un amarillo oscuro (dorado)
        foregroundColor: Colors.white,             // El icono (+) será blanco
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
      ),
      
      textSelectionTheme: base.textSelectionTheme.copyWith(
        cursorColor: Colors.black,
        selectionColor: Colors.black.withOpacity(0.3),
        selectionHandleColor: Colors.black,
      ),

      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        labelStyle: GoogleFonts.lato(color: Colors.grey[700]),
        floatingLabelStyle: GoogleFonts.lato(color: Colors.black),
      ),

      textTheme: GoogleFonts.latoTextTheme(base.textTheme).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ).copyWith(
        titleMedium: GoogleFonts.lato(color: Colors.black87, fontSize: 16),
      ),
    );
  }
}