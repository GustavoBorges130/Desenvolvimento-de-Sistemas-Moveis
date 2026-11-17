// =============================================================================
// Passo 03 do desafio - diretório routes (lib/src/routes):
// "criar classe com constantes que definem o nome da rota das telas do
// aplicativo".
// =============================================================================

/// Nomes das rotas das telas do aplicativo.
///
/// Usar constantes evita erros de digitação ao navegar, por exemplo:
/// `Navigator.of(context).pushNamed(AppRoutes.history)`.
class AppRoutes {
  // Construtor privado: classe usada só pelas constantes.
  AppRoutes._();

  /// Tela de abertura (splash), primeira a ser exibida.
  static const String initial = '/';

  /// Tela principal, com a consulta de CEP e o último endereço consultado.
  static const String home = '/home';

  /// Tela com o histórico de endereços consultados.
  static const String history = '/history';
}
