// =============================================================================
// Passo 03 do desafio - shared/colors:
// "criar classe com as cores usadas no aplicativo".
// =============================================================================

import 'package:material_ui/material_ui.dart';

/// Paleta de cores do FastLocation.
///
/// Centralizar as cores aqui evita valores soltos pelas telas e facilita
/// ajustar a identidade visual da FastDelivery em um único lugar.
///
/// As cores estão no formato 0xAARRGGBB: os dois primeiros dígitos depois
/// do "0x" são a opacidade (FF = totalmente opaca) e os demais são o RGB.
class AppColors {
  // Construtor privado: classe usada só pelas constantes.
  AppColors._();

  // ---------------------------------------------------------------------------
  // Marca
  // ---------------------------------------------------------------------------

  /// Azul principal (barra superior, botões e tela de abertura).
  static const Color primary = Color(0xFF1B3A6B);

  /// Variação escura do azul principal.
  static const Color primaryDark = Color(0xFF0F2547);

  /// Azul bem claro, usado em fundos de ícones e textos sobre o azul.
  static const Color primaryLight = Color(0xFFE6ECF5);

  /// Laranja de destaque (botão "Nova consulta", CEP em destaque).
  static const Color accent = Color(0xFFFF8A00);

  /// Laranja bem claro, usado no fundo da etiqueta do CEP.
  static const Color accentLight = Color(0xFFFFF1E0);

  // ---------------------------------------------------------------------------
  // Superfícies
  // ---------------------------------------------------------------------------

  /// Fundo das telas.
  static const Color background = Color(0xFFF5F7FA);

  /// Fundo dos cartões e campos de texto.
  static const Color surface = Color(0xFFFFFFFF);

  /// Bordas e linhas divisórias.
  static const Color divider = Color(0xFFE3E7ED);

  /// Preto semitransparente que escurece a tela durante o loading.
  static const Color overlay = Color(0x8A000000);

  // ---------------------------------------------------------------------------
  // Textos
  // ---------------------------------------------------------------------------

  /// Texto principal (títulos e informações importantes).
  static const Color textPrimary = Color(0xFF1F2937);

  /// Texto de apoio (descrições, datas).
  static const Color textSecondary = Color(0xFF6B7280);

  /// Texto sobre fundos coloridos (azul ou laranja).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Estados
  // ---------------------------------------------------------------------------

  /// Sucesso.
  static const Color success = Color(0xFF2E7D32);

  /// Erros (avisos de falha na consulta).
  static const Color error = Color(0xFFD32F2F);

  /// Alerta (ícone de endereço não encontrado).
  static const Color warning = Color(0xFFF9A825);
}
