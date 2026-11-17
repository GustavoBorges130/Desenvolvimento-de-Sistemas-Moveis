import 'package:flutter/widgets.dart';

import 'src/app_widget.dart';
import 'src/shared/storage/hive_config.dart';

/// Ponto de entrada do FastLocation.
///
/// O main() prepara o ambiente do Flutter, inicializa o armazenamento local
/// e só então exibe o widget raiz; toda a configuração visual e de rotas está
/// em [AppWidget].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveConfig.start();

  runApp(const AppWidget());
}
