// =============================================================================
// Passo 03 do desafio - shared/metrics:
// "criar classe com constantes que definem valores de espaçamentos".
// =============================================================================

/// Constantes de espaçamento, raio de borda e tamanhos usados no aplicativo.
///
/// Os valores seguem uma escala de 4 em 4 pontos, mantendo as telas
/// alinhadas e consistentes entre si. Em vez de escrever
/// `SizedBox(height: 16)`, as telas usam `SizedBox(height: AppMetrics.spaceL)`.
class AppMetrics {
  // Construtor privado: classe usada só pelas constantes.
  AppMetrics._();

  // ---------------------------------------------------------------------------
  // Espaçamentos (do menor para o maior)
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Raio das bordas arredondadas
  // ---------------------------------------------------------------------------
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 20;

  // ---------------------------------------------------------------------------
  // Tamanhos de ícones
  // ---------------------------------------------------------------------------
  static const double iconS = 18;
  static const double iconM = 24;
  static const double iconL = 48;
  static const double iconXL = 72;

  // ---------------------------------------------------------------------------
  // Componentes
  // ---------------------------------------------------------------------------

  /// Altura dos botões principais.
  static const double buttonHeight = 52;

  /// Elevação (sombra) dos cartões. Zero = cartão "chapado", só com borda.
  static const double cardElevation = 0;

  /// Quantidade de consultas recentes exibidas na home.
  static const int recentAddressesLimit = 5;
}
