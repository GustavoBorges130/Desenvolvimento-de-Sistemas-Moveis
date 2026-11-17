// =============================================================================
// Passo 05 do desafio - módulo Home, diretório repositories:
// "criar classe para se comunicar com o armazenamento local".
// =============================================================================

import 'package:hive/hive.dart';

import '../../../shared/storage/storage_keys.dart';
import '../model/address_model.dart';

/// Comunicação com o armazenamento local (Hive).
///
/// Guarda o histórico de endereços consultados usando o CEP (somente
/// números) como chave. Assim, consultar novamente o mesmo CEP apenas
/// atualiza a data da consulta, sem duplicar o registro.
///
/// Também é usado pelo módulo history para carregar e limpar o histórico.
class AddressLocalRepository {
  /// A caixa pode ser informada (nos testes) ou usar a caixa aberta no
  /// HiveConfig.start() (no app).
  AddressLocalRepository({Box<AddressModel>? box})
      : _box = box ?? Hive.box<AddressModel>(StorageKeys.addressHistoryBox);

  final Box<AddressModel> _box;

  /// Histórico completo, do endereço consultado mais recentemente para o
  /// mais antigo.
  Future<List<AddressModel>> getHistory() async {
    // O operador `..` (cascata) ordena a própria lista e a devolve.
    final history = _box.values.toList()
      ..sort((a, b) => _dateOf(b).compareTo(_dateOf(a)));
    return history;
  }

  /// Último endereço consultado ou `null` se ainda não houve consultas.
  Future<AddressModel?> getLastAddress() async {
    final history = await getHistory();
    return history.isEmpty ? null : history.first;
  }

  /// Endereço salvo para o [cep] (somente números), se existir.
  Future<AddressModel?> getByCep(String cep) async => _box.get(cep);

  /// Salva (ou substitui) o endereço usando o CEP como chave.
  Future<void> save(AddressModel address) {
    return _box.put(address.cepDigits, address);
  }

  /// Apaga todo o histórico do aparelho.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Data usada na ordenação; registros sem data ficam no fim da lista.
  static DateTime _dateOf(AddressModel address) =>
      address.consultedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
}
