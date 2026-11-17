import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'storage_keys.dart';

/// Configuração do armazenamento local com Hive.
///
/// Deve ser chamada uma única vez no main(), antes de o app ser exibido.
class HiveConfig {
  HiveConfig._();

  static Future<void> start() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(
      documentsDirectory.path,
      StorageKeys.databaseFolder,
    );

    Hive.init(databasePath);
  }
}
