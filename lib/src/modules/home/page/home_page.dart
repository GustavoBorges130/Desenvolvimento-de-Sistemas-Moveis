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
  late final HomeController controller = widget.controller ??
      HomeController(
        AddressService(
          remoteRepository: AddressRepository(),
          localRepository: AddressLocalRepository(),
          locationRepository: LocationRepository(),
        ),
      );

  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();

    _disposers.addAll([
      // Erros das consultas viram um aviso na parte de baixo da tela.
      reaction<String?>((_) => controller.errorMessage, _showError),
      // Busca por endereço com vários resultados: abre a lista para escolha.
      reaction<List<AddressModel>?>(
        (_) => controller.searchResults,
        _onSearchResults,
      ),
    ]);

    controller.loadData();
  }

  @override
  void dispose() {
    for (final dispose in _disposers) {
      dispose();
    }
    super.dispose();
  }

  void _showError(String? message) {
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

    controller.clearError();
  }

  void _onSearchResults(List<AddressModel>? results) {
    if (results == null || results.isEmpty) return;

    // A reação dispara no fim da ação do MobX que fez a busca; a lista é
    // aberta no próximo quadro, já fora dessa ação.
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _showSearchResults(results))
      ..ensureVisualUpdate();
  }

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
        onSelect: (address) => Navigator.of(sheetContext).pop(address),
      ),
    );

    if (selected != null) {
      await controller.selectAddress(selected);
    } else {
      controller.clearSearchResults();
    }
  }

  /// Ação: nova consulta.
  Future<void> _openSearch() async {
    final request = await SearchAddressComponent.show(context);
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
    final location = await controller.getLastAddressLocation();
    if (address == null || location == null || !mounted) return;

    try {
      final maps = await MapLauncher.installedMaps;
      if (maps.isEmpty) {
        controller.showError(
          'Nenhum aplicativo de mapas foi encontrado no aparelho.',
        );
        return;
      }

      final map = maps.length == 1 ? maps.first : await _chooseMap(maps);
      if (map == null) return;

      await map.showDirections(
        destination: Coords(location.latitude, location.longitude),
        destinationTitle: '${address.streetLine} - ${address.formattedCep}',
        directionsMode: DirectionsMode.driving,
      );
    } catch (_) {
      controller.showError('Não foi possível abrir o aplicativo de mapas.');
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
              IconButton(
                key: const Key('historyButton'),
                tooltip: 'Histórico de consultas',
                icon: const Icon(Icons.history),
                onPressed: _openHistory,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('newSearchButton'),
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            label: const Text('Nova consulta'),
          ),
          body: RefreshIndicator(
            onRefresh: controller.loadData,
            child: Observer(
              builder: (_) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
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
                  if (controller.showEmptySearch)
                    EmptySearchComponent(
                      notFoundMessage: controller.notFoundMessage,
                      onNewSearch: _openSearch,
                    )
                  else
                    LastAddressComponent(
                      address: controller.lastAddress!,
                      onTraceRoute: _traceRoute,
                    ),
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
                      onTap: controller.selectAddress,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Observer(
          builder: (_) => controller.isLoading
              ? LoadingComponent(message: controller.loadingMessage)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

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
