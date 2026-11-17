// =============================================================================
// Passo 05 do desafio - módulo Home, diretório controller:
// "criar classe com a dependência MobX para controlar a página e usar os
// recursos da classe de services".
// =============================================================================

import 'package:geocoding/geocoding.dart';
import 'package:mobx/mobx.dart';

import '../../../shared/metrics/app_metrics.dart';
import '../model/address_exceptions.dart';
import '../model/address_model.dart';
import '../service/address_service.dart';

// Arquivo gerado pelo mobx_codegen (comando build_runner). Ele cria o mixin
// _$HomeController, que transforma os campos @observable em valores
// observáveis e os métodos @action em ações do MobX.
part 'home_controller.g.dart';

/// Controller (store do MobX) da tela Home.
///
/// Padrão do MobX com geração de código: a classe pública junta a classe
/// base (com a lógica) e o mixin gerado (com a reatividade).
class HomeController = _HomeControllerBase with _$HomeController;

abstract class _HomeControllerBase with Store {
  _HomeControllerBase(this._service);

  /// Regras de negócio e acesso aos dados.
  final AddressService _service;

  static const String genericErrorMessage =
      'Algo deu errado na consulta. Tente novamente.';

  // ---------------------------------------------------------------------------
  // Estado observável (@observable)
  // Quando um destes valores muda, os widgets Observer que o leem são
  // reconstruídos automaticamente e as reações da tela são disparadas.
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Valores derivados (@computed)
  // São recalculados sozinhos quando os observáveis que eles usam mudam.
  // ---------------------------------------------------------------------------

  /// Já existe um endereço consultado?
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

  /// Existe alguma consulta recente para mostrar?
  @computed
  bool get hasRecentAddresses => recentAddresses.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Ações (@action)
  // Os observáveis só são alterados dentro de ações. Nas ações assíncronas
  // (async), o MobX agrupa as alterações feitas depois de cada `await`.
  // ---------------------------------------------------------------------------

  /// Carrega o último endereço e o histórico salvos no aparelho.
  ///
  /// Chamada quando a home abre e quando o usuário volta do histórico.
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
      // CEP inexistente: mostra o componente "Endereço não encontrado".
      notFoundMessage = error.message;
    } on AddressException catch (error) {
      // CEP inválido ou falha de conexão: vira aviso de erro na tela.
      errorMessage = error.message;
    } catch (_) {
      // Qualquer erro inesperado.
      errorMessage = genericErrorMessage;
    } finally {
      // Com sucesso ou erro, o loading sempre é escondido no fim.
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
        // Nenhum CEP para esse endereço.
        notFoundMessage = 'Não encontramos CEPs para "${street.trim()}" em '
            '${city.trim()} - ${uf.toUpperCase()}.';
      } else if (results.length == 1) {
        // Só um resultado: não precisa perguntar ao usuário.
        await _showAddress(results.first);
      } else {
        // Vários resultados: a tela abre a lista para escolha (reação).
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
      // Salva no histórico com a data de agora e coloca em destaque.
      final consulted = await _service.registerConsult(address);
      await _showAddress(consulted);
    } catch (_) {
      errorMessage = 'Não foi possível salvar o endereço no histórico.';
    }
  }

  /// O usuário fechou a lista de resultados sem escolher nenhum.
  @action
  void clearSearchResults() => searchResults = null;

  /// Esconde a mensagem de "não encontrado".
  @action
  void clearNotFound() => notFoundMessage = null;

  /// Usado pela tela para avisar erros que acontecem fora do controller
  /// (por exemplo, nenhum app de mapas instalado).
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

  // ---------------------------------------------------------------------------
  // Métodos auxiliares (sempre chamados de dentro das ações acima)
  // ---------------------------------------------------------------------------

  /// Mostra o loading com a [message] e limpa o erro anterior.
  void _startLoading(String message) {
    errorMessage = null;
    loadingMessage = message;
    isLoading = true;
  }

  /// Coloca o endereço em destaque e recarrega o histórico.
  Future<void> _showAddress(AddressModel address) async {
    lastAddress = address;
    notFoundMessage = null;
    searchResults = null;

    final updatedHistory = await _service.getHistory();
    history = ObservableList.of(updatedHistory);
  }
}
