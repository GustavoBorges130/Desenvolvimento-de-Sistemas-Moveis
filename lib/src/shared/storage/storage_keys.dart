/// Nomes das caixas (boxes) e pastas usadas pelo Hive.
class StorageKeys {
  StorageKeys._();

  /// Pasta, dentro do diretório de documentos do app, onde o Hive grava os
  /// arquivos do banco local.
  static const String databaseFolder = 'fast_location_db';

  /// Caixa com o histórico de endereços consultados.
  static const String addressHistoryBox = 'address_history';
}

/// Identificadores dos adapters do Hive. Cada classe persistida precisa de
/// um typeId único e que nunca deve ser reaproveitado.
class HiveTypeIds {
  HiveTypeIds._();

  static const int address = 0;
}
