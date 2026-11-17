// =============================================================================
// Passo 05 do desafio - módulo Home, diretório components:
// "criar classe para definir componente de busca vazia de endereço".
// Resultado esperado: "componente para apresentar resultados não encontrados
// da busca realizada".
// =============================================================================

import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/message_component.dart';

/// Componente de busca vazia.
///
/// Aparece em dois casos:
/// * nenhuma consulta foi feita ainda ([notFoundMessage] nulo);
/// * a última busca não encontrou resultados ([notFoundMessage] preenchido).
class EmptySearchComponent extends StatelessWidget {
  const EmptySearchComponent({
    super.key,
    this.notFoundMessage,
    this.onNewSearch,
  });

  /// Mensagem do "não encontrado". Nula quando ainda não houve consulta.
  final String? notFoundMessage;

  /// Ação do botão para fazer uma nova busca.
  final VoidCallback? onNewSearch;

  /// A última busca não encontrou nada?
  bool get isNotFound => notFoundMessage != null;

  @override
  Widget build(BuildContext context) {
    // Reaproveita o componente compartilhado de mensagem, trocando ícone,
    // cor e textos conforme o caso.
    return Card(
      child: MessageComponent(
        icon: isNotFound ? Icons.search_off_rounded : Icons.travel_explore,
        iconColor: isNotFound ? AppColors.warning : AppColors.primary,
        title: isNotFound
            ? 'Endereço não encontrado'
            : 'Nenhuma consulta realizada',
        // `??` usa o texto padrão quando não há mensagem de não encontrado.
        message: notFoundMessage ??
            'Consulte um CEP ou busque o CEP de um endereço para ver os '
                'dados da entrega aqui.',
        action: onNewSearch == null
            ? null
            : OutlinedButton.icon(
                onPressed: onNewSearch,
                icon: const Icon(Icons.search),
                label: Text(isNotFound ? 'Tentar outra busca' : 'Nova consulta'),
              ),
      ),
    );
  }
}
