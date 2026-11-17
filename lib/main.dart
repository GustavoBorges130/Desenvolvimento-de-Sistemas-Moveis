import 'package:flutter/widgets.dart';

import 'src/app_widget.dart';

/// Ponto de entrada do FastLocation.
///
/// O main() fica responsável apenas por preparar o ambiente do Flutter e
/// iniciar o widget raiz; toda a configuração visual e de rotas está em
/// [AppWidget].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppWidget());
}
