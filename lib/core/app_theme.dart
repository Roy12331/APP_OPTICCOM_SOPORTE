import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de tenerlo instalado

class AppTheme {
  // 1. Paleta de Colores Corporativa
  static const Color primary = Color(0xFFFF9800); // Naranja Opticcom (Acción)
  static const Color secondary = Color(
    0xFF0F172A,
  ); // Azul Marino/Noche Profundo (Tecnología)
  static const Color background = Color(0xFFF8F9FA); // Gris muy claro
  static const Color textDark = Color(0xFF1E293B); // Texto oscuro suave
  static const Color textLight = Color(0xFF64748B); // Texto secundario

  // 2. Tema Global
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ),
      // Tipografía global Poppins (muy redonda y moderna)
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.poppins(color: textDark),
        bodyMedium: GoogleFonts.poppins(color: textLight),
      ),
    );
  }
}
