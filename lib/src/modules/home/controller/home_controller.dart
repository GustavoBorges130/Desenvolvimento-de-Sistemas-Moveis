import 'package:geocoding/geocoding.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/metrics/app_metrics.dart';
import '../model/address_exceptions.dart';
import '../model/address_model.dart';
import '../service/address_service.dart';

part 'home_controller.g.dart';

/// Controller (store do MobX) da tela Home.
class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  _HomeControllerBase(this._service);

  final AddressService _service;

  static const String genericErrorMessage =
      'Algo deu errado na consulta. Tente novamente.';

  /// Indica que há uma consulta externa em andamento (exibe o loading).
  @observable
  bool isLoading = false;

  /// Texto exibido na tela de loading.
  @observable
  String loadingMessage = '';

  /// Último endereço consultado.
  @observable
  AddressModel? lastAddress;

  /// Histórico de endereços, do mais recente para o mais antigo.
  @observable
  ObservableList<AddressModel> history = ObservableList<AddressModel>();

  /// Resultados da busca por endereço que aguardam a escolha do usuário.
  ///
  /// Sempre recebe uma nova lista, para que a reação da tela seja disparada
  /// a cada busca.
  @observable
  List<AddressModel>? searchResults;

  /// Mensagem de erro da última ação. Observada por uma reação na tela.
  @observable
  String? errorMessage;

  /// Preenchida quando a última busca não encontrou nenhum endereço.
  @observable
  String? notFoundMessage;

  @computed
  bool get hasLastAddress => lastAddress != null;

  /// Mostra o componente de busca vazia: nenhuma consulta feita ainda ou a
  /// última busca não encontrou resultados.
  @computed
  bool get showEmptySearch => notFoundMessage != null || lastAddress == null;

  /// Consultas recentes exibidas na home (sem repetir o endereço que já
  /// aparece em destaque como último consultado).
  @computed
  List<AddressModel> get recentAddresses {
    final highlightedCep = showEmptySearch ? null : lastAddress?.cepDigits;
    return history
        .where((address) => address.cepDigits != highlightedCep)
        .take(AppMetrics.recentAddressesLimit)
        .toList();
  }

  @computed
  bool get hasRecentAddresses => recentAddresses.isNotEmpty;

  /// Carrega o último endereço e o histórico salvos no aparelho.
  @action
  Future<void> loadData() async {
    try {
      final storedHistory = await _service.getHistory();
      history = ObservableList.of(storedHistory);
      lastAddress = storedHistory.isEmpty ? null : storedHistory.first;
    } catch (_) {
      errorMessage = 'Não foi possível carregar o histórico de consultas.';
    }
  }

  /// Nova consulta por CEP.
  @action
  Future<void> searchByCep(String cep) async {
    _startLoading('Consultando CEP...');
    try {
      final address = await _service.getAddressByCep(cep);
      await _showAddress(address);
    } on AddressNotFoundException catch (error) {
      notFoundMessage = error.message;
    } on AddressException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = genericErrorMessage;
    } finally {
      isLoading = false;
    }
  }

  /// Nova consulta por endereço completo ou parcial.
  ///
  /// Um único resultado já vira o último endereço consultado; vários
  /// resultados ficam em [searchResults] para o usuário escolher.
  @action
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    _startLoading('Buscando endereços...');
    try {
      final results = await _service.searchAddresses(
        uf: uf,
        city: city,
        street: street,
      );

      if (results.isEmpty) {
        notFoundMessage = 'Não encontramos CEPs para "${street.trim()}" em '
            '${city.trim()} - ${uf.toUpperCase()}.';
      } else if (results.length == 1) {
        await _showAddress(results.first);
      } else {
        searchResults = List.unmodifiable(results);
      }
    } on AddressException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = genericErrorMessage;
    } finally {
      isLoading = false;
    }
  }

  /// Define [address] (vindo da busca, das consultas recentes ou do
  /// histórico) como o último endereço consultado.
  @action
  Future<void> selectAddress(AddressModel address) async {
    errorMessage = null;
    searchResults = null;
    try {
      final consulted = await _service.registerConsult(address);
      await _showAddress(consulted);
    } catch (_) {
      errorMessage = 'Não foi possível salvar o endereço no histórico.';
    }
  }

  @action
  void clearSearchResults() => searchResults = null;

  @action
  void clearNotFound() => notFoundMessage = null;

  @action
  void showError(String message) => errorMessage = message;

  /// Chamado pela tela depois de exibir o erro, para que a mesma mensagem
  /// possa ser exibida de novo numa próxima falha.
  @action
  void clearError() => errorMessage = null;

  /// Coordenadas do último endereço consultado, usadas para traçar a rota.
  ///
  /// Retorna `null` (e preenche [errorMessage]) se não for possível
  /// localizar o endereço.
  @action
  Future<Location?> getLastAddressLocation() async {
    final address = lastAddress;
    if (address == null) {
      errorMessage = 'Consulte um endereço antes de traçar a rota.';
      return null;
    }

    _startLoading('Localizando endereço no mapa...');
    try {
      return await _service.getCoordinates(address);
    } on AddressException catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = const AddressLocationException().message;
      return null;
    } finally {
      isLoading = false;
    }
  }

  void _startLoading(String message) {
    errorMessage = null;
    loadingMessage = message;
    isLoading = true;
  }

  Future<void> _showAddress(AddressModel address) async {
    lastAddress = address;
    notFoundMessage = null;
    searchResults = null;

    final updatedHistory = await _service.getHistory();
    history = ObservableList.of(updatedHistory);
  }
}
