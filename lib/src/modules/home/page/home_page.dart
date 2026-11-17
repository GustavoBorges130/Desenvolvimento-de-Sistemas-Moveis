// =============================================================================
// Passo 05 do desafio - módulo Home, diretório page:
// "criar classe com gerenciamento de estado:
//  - usar o controller previamente criado;
//  - usar o widget Observer do MobX Flutter, para usar a reatividade na tela;
//  - usar reações do MobX para cenários de erros nas consultas;
//  - implementar ações para: nova consulta; acesso ao histórico de consultas
//    (nova página); traçar a rota com o último endereço consultado."
// =============================================================================

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/loading_component.dart';
import '../../../shared/components/section_title_component.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list_component.dart';
import '../components/empty_search_component.dart';
import '../components/last_address_component.dart';
import '../components/search_address_component.dart';
import '../controller/home_controller.dart';
import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/address_repository.dart';
import '../repositories/location_repository.dart';
import '../service/address_service.dart';

/// Tela principal do FastLocation.
///
/// Mostra o último endereço consultado, as consultas recentes e oferece as
/// ações de nova consulta, acesso ao histórico e traçar rota.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  /// Permite injetar um controller (usado nos testes). Quando nulo, a tela
  /// monta o controller com os repositórios reais.
  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Controller (store do MobX) da tela.
  ///
  /// Monta a cadeia de dependências: repositórios -> service -> controller.
  /// `late final` faz a criação acontecer só no primeiro uso.
  late final HomeController controller = widget.controller ??
      HomeController(
        AddressService(
          remoteRepository: AddressRepository(),
          localRepository: AddressLocalRepository(),
          locationRepository: LocationRepository(),
        ),
      );

  /// Funções que desligam as reações do MobX quando a tela é fechada.
  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();

    // Reações do MobX: executam um efeito (mostrar aviso, abrir lista)
    // sempre que o valor observado muda. Diferente do Observer, elas não
    // redesenham widgets; servem para ações pontuais na tela.
    _disposers.addAll([
      // Erros das consultas viram um aviso na parte de baixo da tela.
      reaction<String?>((_) => controller.errorMessage, _showError),
      // Busca por endereço com vários resultados: abre a lista para escolha.
      reaction<List<AddressModel>?>(
        (_) => controller.searchResults,
        _onSearchResults,
      ),
    ]);

    // Carrega o histórico salvo no aparelho ao abrir a tela.
    controller.loadData();
  }

  @override
  void dispose() {
    // Desliga as reações para não continuarem rodando depois que a tela
    // foi fechada.
    for (final dispose in _disposers) {
      dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Efeitos das reações
  // ---------------------------------------------------------------------------

  /// Mostra o erro da consulta em um SnackBar vermelho.
  void _showError(String? message) {
    // A reação também dispara quando o erro é limpo (null); nesse caso não
    // há nada para mostrar.
    if (message == null || !mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.textOnPrimary),
              const SizedBox(width: AppMetrics.spaceM),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );

    // Limpa o erro para que a mesma mensagem possa aparecer de novo numa
    // próxima falha (a reação só dispara quando o valor muda).
    controller.clearError();
  }

  /// Recebe os resultados da busca por endereço.
  void _onSearchResults(List<AddressModel>? results) {
    if (results == null || results.isEmpty) return;

    // A reação dispara no fim da ação do MobX que fez a busca; a lista é
    // aberta no próximo quadro, já fora dessa ação.
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _showSearchResults(results))
      ..ensureVisualUpdate();
  }

  /// Abre a lista de endereços encontrados para o usuário escolher.
  Future<void> _showSearchResults(List<AddressModel> results) async {
    if (!mounted) return;

    final selected = await showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (sheetContext) => _SearchResultsSheet(
        results: results,
        // Fecha a lista devolvendo o endereço tocado.
        onSelect: (address) => Navigator.of(sheetContext).pop(address),
      ),
    );

    if (selected != null) {
      // Endereço escolhido vira o último consultado.
      await controller.selectAddress(selected);
    } else {
      // Lista fechada sem escolha.
      controller.clearSearchResults();
    }
  }

  // ---------------------------------------------------------------------------
  // Ações da tela
  // ---------------------------------------------------------------------------

  /// Ação: nova consulta.
  ///
  /// Abre o formulário e, conforme o tipo escolhido, pede ao controller a
  /// consulta por CEP ou por endereço.
  Future<void> _openSearch() async {
    final request = await SearchAddressComponent.show(context);
    // Formulário fechado sem consultar.
    if (request == null) return;

    if (request.type == SearchType.cep) {
      await controller.searchByCep(request.cep);
    } else {
      await controller.searchByAddress(
        uf: request.uf,
        city: request.city,
        street: request.street,
      );
    }
  }

  /// Ação: acesso ao histórico de consultas (nova página).
  ///
  /// Ao tocar em um endereço do histórico, ele volta para a home como o
  /// último endereço consultado.
  Future<void> _openHistory() async {
    // pushNamed devolve o valor passado no Navigator.pop() da outra tela.
    final selected = await Navigator.of(context).pushNamed<AddressModel>(
      AppRoutes.history,
    );

    // O histórico pode ter sido limpo na outra tela.
    await controller.loadData();
    if (selected != null) await controller.selectAddress(selected);
  }

  /// Ação: traçar a rota da localização atual até o último endereço.
  ///
  /// O endereço é convertido em coordenadas (geocoding) e o app de mapas
  /// escolhido abre o trajeto partindo da posição atual do aparelho.
  Future<void> _traceRoute() async {
    final address = controller.lastAddress;

    // 1) Endereço -> latitude/longitude (o controller mostra o loading e
    //    avisa o erro, se não conseguir).
    final location = await controller.getLastAddressLocation();
    if (address == null || location == null || !mounted) return;

    try {
      // 2) Lista os apps de mapas instalados (Google Maps, Waze...).
      final maps = await MapLauncher.installedMaps;
      if (maps.isEmpty) {
        controller.showError(
          'Nenhum aplicativo de mapas foi encontrado no aparelho.',
        );
        return;
      }

      // 3) Se houver mais de um, o usuário escolhe qual abrir.
      final map = maps.length == 1 ? maps.first : await _chooseMap(maps);
      if (map == null) return;

      // 4) Abre a rota. Sem informar a origem, o app de mapas parte da
      //    localização atual do aparelho.
      await map.showDirections(
        destination: Coords(location.latitude, location.longitude),
        destinationTitle: '${address.streetLine} - ${address.formattedCep}',
        directionsMode: DirectionsMode.driving,
      );
    } catch (_) {
      controller.showError('Não foi possível abrir o aplicativo de mapas.');
    }
  }

  /// Mostra a lista de apps de mapas para o usuário escolher.
  Future<AvailableMap?> _chooseMap(List<AvailableMap> maps) {
    return showModalBottomSheet<AvailableMap>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppMetrics.spaceS),
              child: SectionTitleComponent(
                title: 'Abrir rota com...',
                icon: Icons.map_outlined,
              ),
            ),
            for (final map in maps)
              ListTile(
                leading: const Icon(Icons.map, color: AppColors.primary),
                title: Text(map.mapName),
                onTap: () => Navigator.of(sheetContext).pop(map),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // O Stack coloca o loading por cima da tela inteira (inclusive da barra
    // superior e do botão flutuante).
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.local_shipping_rounded, color: AppColors.accent),
                SizedBox(width: AppMetrics.spaceS),
                Text('FastLocation'),
              ],
            ),
            actions: [
              // Ação: acesso ao histórico de consultas.
              IconButton(
                key: const Key('historyButton'),
                tooltip: 'Histórico de consultas',
                icon: const Icon(Icons.history),
                onPressed: _openHistory,
              ),
            ],
          ),
          // Ação: nova consulta.
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('newSearchButton'),
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            label: const Text('Nova consulta'),
          ),
          // Puxar a tela para baixo recarrega o histórico.
          body: RefreshIndicator(
            onRefresh: controller.loadData,
            // Observer: redesenha este trecho sempre que algum observável
            // usado dentro dele mudar (último endereço, histórico, etc.).
            child: Observer(
              builder: (_) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
                  // Espaço extra no fim para o botão flutuante não cobrir
                  // o último item.
                  AppMetrics.spaceXXXL * 2,
                ),
                children: [
                  const _HomeHeader(),
                  const SizedBox(height: AppMetrics.spaceXL),
                  SectionTitleComponent(
                    title: controller.notFoundMessage != null
                        ? 'Resultado da busca'
                        : 'Último endereço consultado',
                    icon: Icons.place_outlined,
                  ),

                  // Busca vazia / não encontrado OU o último endereço.
                  if (controller.showEmptySearch)
                    EmptySearchComponent(
                      notFoundMessage: controller.notFoundMessage,
                      onNewSearch: _openSearch,
                    )
                  else
                    LastAddressComponent(
                      // `!` é seguro aqui: showEmptySearch é falso só quando
                      // existe um último endereço.
                      address: controller.lastAddress!,
                      onTraceRoute: _traceRoute,
                    ),

                  // Consultas recentes (lista de endereços consultados).
                  if (controller.hasRecentAddresses) ...[
                    const SizedBox(height: AppMetrics.spaceXL),
                    SectionTitleComponent(
                      title: 'Consultas recentes',
                      icon: Icons.history,
                      trailing: TextButton(
                        onPressed: _openHistory,
                        child: const Text('Ver histórico'),
                      ),
                    ),
                    AddressListComponent(
                      addresses: controller.recentAddresses,
                      // Tocar numa consulta recente a coloca em destaque.
                      onTap: controller.selectAddress,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // Tela de loading: aparece enquanto o controller indica uma consulta
        // em andamento.
        Observer(
          builder: (_) => controller.isLoading
              ? LoadingComponent(message: controller.loadingMessage)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Faixa azul de boas-vindas no topo da home.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppMetrics.spaceL),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppMetrics.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, entregador!',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppMetrics.spaceXS),
                Text(
                  'Confira o CEP ou o endereço da entrega e trace a rota '
                  'até o destino.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppMetrics.spaceM),
          const Icon(
            Icons.route_rounded,
            size: AppMetrics.iconL,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

/// Lista dos endereços encontrados na busca por endereço, para o usuário
/// escolher qual é o da entrega.
class _SearchResultsSheet extends StatelessWidget {
  const _SearchResultsSheet({required this.results, required this.onSelect});

  final List<AddressModel> results;
  final ValueChanged<AddressModel> onSelect;

  @override
  Widget build(BuildContext context) {
    // Limita a lista a 75% da altura da tela.
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMetrics.pagePadding,
            ),
            child: SectionTitleComponent(
              title: results.length == 1
                  ? '1 endereço encontrado'
                  : '${results.length} endereços encontrados',
              icon: Icons.checklist_rounded,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppMetrics.pagePadding,
              0,
              AppMetrics.pagePadding,
              AppMetrics.spaceM,
            ),
            child: Text(
              'Toque no endereço da entrega para ver os detalhes.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          // Flexible deixa a lista rolar dentro do espaço disponível.
          Flexible(
            child: AddressListComponent(
              addresses: results,
              onTap: onSelect,
              showConsultedAt: false,
              scrollable: true,
              padding: const EdgeInsets.fromLTRB(
                AppMetrics.pagePadding,
                0,
                AppMetrics.pagePadding,
                AppMetrics.spaceXL,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
