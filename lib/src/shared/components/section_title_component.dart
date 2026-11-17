// =============================================================================
// Passo 03 do desafio - shared/components:
// componente compartilhado entre os módulos do aplicativo.
// =============================================================================

import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Título de seção usado para separar blocos de conteúdo nas telas.
///
/// Exemplo de uso na home: "Último endereço consultado" e
/// "Consultas recentes".
class SectionTitleComponent extends StatelessWidget {
  const SectionTitleComponent({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  /// Texto do título.
  final String title;

  /// Ícone opcional exibido antes do título.
  final IconData? icon;

  /// Widget opcional exibido à direita (por exemplo, o botão
  /// "Ver histórico").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppMetrics.spaceS),
      child: Row(
        children: [
          // O ícone só aparece quando foi informado.
          if (icon != null) ...[
            Icon(icon, size: AppMetrics.iconS, color: AppColors.primary),
            const SizedBox(width: AppMetrics.spaceS),
          ],
          // Expanded faz o título ocupar o espaço livre, empurrando o
          // `trailing` para a direita.
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          // Escrito com `if` (e não com a sintaxe `?trailing`) porque o
          // hive_generator usado no projeto não reconhece essa sintaxe nova.
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
