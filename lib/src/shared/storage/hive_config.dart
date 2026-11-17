// =============================================================================
// Passo 03 do desafio - shared/storage:
// "criar classes que definem a configuração e arquivos relacionados ao
// armazenamento local".
// =============================================================================

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
  // Construtor privado: classe usada só pelos métodos estáticos.
  HiveConfig._();

  /// Inicializa o Hive.
  static Future<void> start() async {
    // path_provider: descobre a pasta de documentos do app no aparelho
    // (diferente no Android e no iOS).
    final documentsDirectory = await getApplicationDocumentsDirectory();

    // path: monta o caminho da pasta do banco com o separador correto do
    // sistema, por exemplo ".../Documents/fast_location_db".
    final databasePath = path.join(
      documentsDirectory.path,
      StorageKeys.databaseFolder,
    );

    Hive.init(databasePath);
    registerAdapters();
    await openBoxes();
  }

  /// Registra os adapters que ensinam o Hive a gravar e ler as classes do
  /// app. O AddressModelAdapter é gerado pelo hive_generator no arquivo
  /// `address_model.g.dart`.
  static void registerAdapters() {
    // A verificação evita erro se o método for chamado mais de uma vez
    // (por exemplo, nos testes).
    if (!Hive.isAdapterRegistered(HiveTypeIds.address)) {
      Hive.registerAdapter(AddressModelAdapter());
    }
  }

  /// Abre as caixas usadas pelo app. Depois de abertas, os repositórios
  /// acessam cada uma com `Hive.box(...)` sem precisar de `await`.
  static Future<void> openBoxes() async {
    await Hive.openBox<AddressModel>(StorageKeys.addressHistoryBox);
  }
}
