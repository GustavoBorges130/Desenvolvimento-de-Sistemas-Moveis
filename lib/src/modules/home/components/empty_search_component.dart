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

  final String? notFoundMessage;
  final VoidCallback? onNewSearch;

  bool get isNotFound => notFoundMessage != null;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: MessageComponent(
        icon: isNotFound ? Icons.search_off_rounded : Icons.travel_explore,
        iconColor: isNotFound ? AppColors.warning : AppColors.primary,
        title: isNotFound
            ? 'Endereço não encontrado'
            : 'Nenhuma consulta realizada',
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
