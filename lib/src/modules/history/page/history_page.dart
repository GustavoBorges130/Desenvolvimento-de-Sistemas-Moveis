// =============================================================================
// Passo 06 do desafio - módulo history, diretório page:
// "criar classe com gerenciamento de estado:
//  - usar o controller previamente criado;
//  - usar o widget Observer do MobX Flutter, para usar a reatividade na tela;
//  - realizar o carregamento automático dos dados históricos ao acessar a
//    página."
// Resultado esperado: "tela para apresentar histórico de endereços
// consultados".
// =============================================================================

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/message_component.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../home/components/address_list_component.dart';
import '../../home/repositories/address_local_repository.dart';
import '../controller/history_controller.dart';

/// Tela com o histórico de endereços consultados.
///
/// Os dados são carregados automaticamente do armazenamento local ao abrir
/// a tela. Tocar em um endereço devolve esse endereço para a home, onde ele
/// passa a ser o último consultado (e pode ser usado para traçar a rota).
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.controller});

  /// Permite injetar um controller (usado nos testes).
  final HistoryController? controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  /// Controller da tela, ligado ao histórico salvo no Hive.
  late final HistoryController controller =
      widget.controller ?? HistoryController(AddressLocalRepository());

  @override
  void initState() {
    super.initState();
    // Carregamento automático dos dados históricos ao acessar a página.
    controller.loadHistory();
  }

  /// Pede confirmação antes de apagar o histórico.
  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text(
          'Todos os endereços consultados neste aparelho serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    // `confirmed` é null se o usuário fechar o diálogo tocando fora dele.
    if (confirmed ?? false) await controller.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de consultas'),
        actions: [
          // Observer: o botão fica desabilitado quando o histórico está
          // vazio e é reativado sozinho quando houver itens.
          Observer(
            builder: (_) => IconButton(
              key: const Key('clearHistoryButton'),
              tooltip: 'Limpar histórico',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: controller.isEmpty ? null : _confirmClear,
            ),
          ),
        ],
      ),
      // Observer: redesenha o corpo da tela conforme o estado do controller
      // (carregando, erro, vazio ou com dados).
      body: Observer(
        builder: (_) {
          // 1) Carregando pela primeira vez.
          if (controller.isLoading && controller.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Erro ao ler o armazenamento local.
          final error = controller.errorMessage;
          if (error != null) {
            return _CenteredMessage(
              child: MessageComponent(
                icon: Icons.error_outline,
                iconColor: AppColors.error,
                title: 'Ops!',
                message: error,
                action: OutlinedButton.icon(
                  onPressed: controller.loadHistory,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ),
            );
          }

          // 3) Nenhuma consulta salva.
          if (controller.isEmpty) {
            return _CenteredMessage(
              child: MessageComponent(
                icon: Icons.history_toggle_off,
                title: 'Nenhuma consulta no histórico',
                message: 'Os endereços que você consultar aparecerão aqui, '
                    'mesmo sem conexão com a internet.',
                action: OutlinedButton.icon(
                  // Volta para a home, onde está o botão de consulta.
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.search),
                  label: const Text('Fazer uma consulta'),
                ),
              ),
            );
          }

          // 4) Lista com o histórico.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total de endereços e dica de uso.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
                  AppMetrics.pagePadding,
                  AppMetrics.spaceS,
                ),
                child: Text(
                  controller.total == 1
                      ? '1 endereço consultado. Toque nele para usá-lo na rota.'
                      : '${controller.total} endereços consultados. Toque em '
                          'um deles para usá-lo na rota.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              Expanded(
                // Puxar a lista para baixo recarrega o histórico.
                child: RefreshIndicator(
                  onRefresh: controller.loadHistory,
                  // Reaproveita o componente de lista do módulo home.
                  child: AddressListComponent(
                    addresses: controller.history.toList(),
                    scrollable: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppMetrics.pagePadding,
                      AppMetrics.spaceS,
                      AppMetrics.pagePadding,
                      AppMetrics.spaceXL,
                    ),
                    // Volta para a home devolvendo o endereço tocado.
                    onTap: (address) => Navigator.of(context).pop(address),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Centraliza uma mensagem na tela, com rolagem para telas pequenas.
class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppMetrics.pagePadding),
        child: child,
      ),
    );
  }
}
