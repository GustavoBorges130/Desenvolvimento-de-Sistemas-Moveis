// =============================================================================
// Passo 06 do desafio - módulo history, diretório controller:
// "criar classe com a dependência mobx para controlar a página e carregar os
// dados históricos do armazenamento local".
// =============================================================================

import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/address_local_repository.dart';

// Arquivo gerado pelo mobx_codegen (comando build_runner).
part 'history_controller.g.dart';

/// Controller (store do MobX) da tela de histórico.
///
/// Carrega do armazenamento local os endereços já consultados no aparelho.
/// Reaproveita o AddressLocalRepository do módulo home, que já sabe ler e
/// apagar o histórico no Hive.
class HistoryController = _HistoryControllerBase with _$HistoryController;

abstract class _HistoryControllerBase with Store {
  _HistoryControllerBase(this._localRepository);

  final AddressLocalRepository _localRepository;

  // ---------------------------------------------------------------------------
  // Estado observável
  // ---------------------------------------------------------------------------

  /// Endereços consultados, do mais recente para o mais antigo.
  @observable
  ObservableList<AddressModel> history = ObservableList<AddressModel>();

  /// Indica que o histórico está sendo carregado.
  @observable
  bool isLoading = false;

  /// Mensagem exibida se não for possível ler o histórico.
  @observable
  String? errorMessage;

  // ---------------------------------------------------------------------------
  // Valores derivados
  // ---------------------------------------------------------------------------

  /// O histórico está vazio?
  @computed
  bool get isEmpty => history.isEmpty;

  /// Quantidade de endereços no histórico.
  @computed
  int get total => history.length;

  // ---------------------------------------------------------------------------
  // Ações
  // ---------------------------------------------------------------------------

  /// Lê o histórico salvo no aparelho. Chamada automaticamente quando a
  /// tela abre e quando o usuário puxa a lista para atualizar.
  @action
  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    try {
      final stored = await _localRepository.getHistory();
      history = ObservableList.of(stored);
    } catch (_) {
      errorMessage = 'Não foi possível carregar o histórico de consultas.';
    } finally {
      isLoading = false;
    }
  }

  /// Apaga todo o histórico do aparelho.
  @action
  Future<void> clearHistory() async {
    try {
      await _localRepository.clear();
      history = ObservableList<AddressModel>();
    } catch (_) {
      errorMessage = 'Não foi possível limpar o histórico.';
    }
  }
}
