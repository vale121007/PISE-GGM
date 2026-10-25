import 'package:flutter/material.dart';

class AppColors {
  static const verde900 = Color(0xFF0F3D2E);
  static const verde700 = Color(0xFF1F6B45);
  static const verde500 = Color(0xFF2D8B57);
  static const verde100 = Color(0xFFE9F3E7);
  static const amarillo500 = Color(0xFFF2C230);
  static const amarillo300 = Color(0xFFF7DB7A);
  static const dorado600 = Color(0xFFB8860B);
  static const blanco = Color(0xFFFFFDF8);
  static const tinta = Color(0xFF17241B);
  static const tintaSuave = Color(0xFF4B5C4E);
  static const borde = Color(0x1F17241B);

  // Formas "hoja" iguales a las de tu web
  static const hojaChica = BorderRadius.only(
    topLeft: Radius.circular(4),
    topRight: Radius.circular(16),
    bottomRight: Radius.circular(4),
    bottomLeft: Radius.circular(16),
  );
  static const hojaMedia = BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(24),
    bottomRight: Radius.circular(6),
    bottomLeft: Radius.circular(24),
  );
  static const hojaGrande = BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(44),
    bottomRight: Radius.circular(6),
    bottomLeft: Radius.circular(44),
  );
}