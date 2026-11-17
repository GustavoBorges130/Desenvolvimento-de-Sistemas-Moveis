import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../modules/home/model/address_model.dart';
import 'storage_keys.dart';

/// Configuração do armazenamento local com Hive.
///
/// Deve ser chamada uma única vez no main(), antes de o app ser exibido:
/// define a pasta do banco, registra os adapters gerados pelo
/// hive_generator e abre as caixas usadas pelos módulos.
class HiveConfig {
  HiveConfig._();

  static Future<void> start() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databasePath = path.join(
      documentsDirectory.path,
      StorageKeys.databaseFolder,
    );

    Hive.init(databasePath);
    registerAdapters();
    await openBoxes();
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTypeIds.address)) {
      Hive.registerAdapter(AddressModelAdapter());
    }
  }

  static Future<void> openBoxes() async {
    await Hive.openBox<AddressModel>(StorageKeys.addressHistoryBox);
  }
}
