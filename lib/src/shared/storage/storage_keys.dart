// =============================================================================
// Passo 03 do desafio - shared/storage:
// "criar classes que definem a configuração e arquivos relacionados ao
// armazenamento local".
// =============================================================================

/// Nomes das caixas (boxes) e pastas usadas pelo Hive.
///
/// No Hive, uma "caixa" funciona como uma tabela chave/valor gravada em
/// arquivo no aparelho.
class StorageKeys {
  // Construtor privado: classe usada só pelas constantes.
  StorageKeys._();

  /// Pasta, dentro do diretório de documentos do app, onde o Hive grava os
  /// arquivos do banco local.
  static const String databaseFolder = 'fast_location_db';

  /// Caixa com o histórico de endereços consultados.
  static const String addressHistoryBox = 'address_history';
}

/// Identificadores dos adapters do Hive. Cada classe persistida precisa de
/// um typeId único e que nunca deve ser reaproveitado.
///
/// O typeId é gravado junto com os dados; se ele mudar, o Hive deixa de
/// reconhecer os registros já salvos.
class HiveTypeIds {
  // Construtor privado: classe usada só pelas constantes.
  HiveTypeIds._();

  /// typeId do AddressModel (endereço consultado).
  static const int address = 0;
}
