// =============================================================================
// FastLocation - ponto de entrada do aplicativo
// Passo 01 do desafio: "Refatorar o método main()".
// =============================================================================

import 'package:flutter/widgets.dart';

import 'src/app_widget.dart';
import 'src/shared/storage/hive_config.dart';

/// Ponto de entrada do FastLocation.
///
/// O main() prepara o ambiente do Flutter, inicializa o armazenamento local
/// e só então exibe o widget raiz; toda a configuração visual e de rotas está
/// em [AppWidget].
///
/// O método é `async` porque a inicialização do Hive (banco local) precisa
/// terminar antes de qualquer tela tentar ler o histórico de consultas.
Future<void> main() async {
  // Garante que o Flutter esteja pronto para usar plugins nativos (como o
  // path_provider) antes do runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Define a pasta do banco local, registra os adapters e abre as caixas.
  await HiveConfig.start();

  // Exibe o widget raiz, que cuida do tema e das rotas do app.
  runApp(const AppWidget());
}
