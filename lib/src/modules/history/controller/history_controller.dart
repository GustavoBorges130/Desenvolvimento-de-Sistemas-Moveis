import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/address_local_repository.dart';

part 'history_controller.g.dart';

/// Controller (store do MobX) da tela de histórico.
///
/// Carrega do armazenamento local os endereços já consultados no aparelho.
class HistoryController = _HistoryControllerBase with _$HistoryController;

abstract class _HistoryControllerBase with Store {
  _HistoryControllerBase(this._localRepository);

  final AddressLocalRepository _localRepository;

  /// Endereços consultados, do mais recente para o mais antigo.
  @observable
  ObservableList<AddressModel> history = ObservableList<AddressModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get isEmpty => history.isEmpty;

  @computed
  int get total => history.length;

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
