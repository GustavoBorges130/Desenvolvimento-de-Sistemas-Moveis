/// Constantes de espaçamento, raio de borda e tamanhos usados no aplicativo.
///
/// Os valores seguem uma escala de 4 em 4 pontos, mantendo as telas
/// alinhadas e consistentes entre si.
class AppMetrics {
  AppMetrics._();

  // Espaçamentos
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXL = 24;
  static const double spaceXXL = 32;
  static const double spaceXXXL = 48;

  /// Margem padrão entre o conteúdo e as bordas da tela.
  static const double pagePadding = spaceL;

  // Bordas
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 20;

  // Ícones
  static const double iconS = 18;
  static const double iconM = 24;
  static const double iconL = 48;
  static const double iconXL = 72;

  // Componentes
  static const double buttonHeight = 52;
  static const double cardElevation = 0;

  /// Quantidade de consultas recentes exibidas na home.
  static const int recentAddressesLimit = 5;
}
