import 'package:material_ui/material_ui.dart';

/// Paleta de cores do FastLocation.
///
/// Centralizar as cores aqui evita valores soltos pelas telas e facilita
/// ajustar a identidade visual da FastDelivery em um único lugar.
class AppColors {
  AppColors._();

  // Marca
  static const Color primary = Color(0xFF1B3A6B);
  static const Color primaryDark = Color(0xFF0F2547);
  static const Color primaryLight = Color(0xFFE6ECF5);
  static const Color accent = Color(0xFFFF8A00);
  static const Color accentLight = Color(0xFFFFF1E0);

  // Superfícies
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE3E7ED);
  static const Color overlay = Color(0x8A000000);

  // Textos
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Estados
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);
}
