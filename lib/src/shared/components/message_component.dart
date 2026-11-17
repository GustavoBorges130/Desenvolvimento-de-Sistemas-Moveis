// =============================================================================
// Passo 03 do desafio - shared/components:
// componente compartilhado entre os módulos do aplicativo.
// =============================================================================

import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Bloco com ícone, título e texto de apoio, usado para estados vazios,
/// avisos e resultados não encontrados.
///
/// É reaproveitado pela home (busca vazia / não encontrado) e pelo
/// histórico (histórico vazio / erro ao carregar).
class MessageComponent extends StatelessWidget {
  const MessageComponent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.primary,
    this.action,
  });

  /// Ícone grande exibido no topo.
  final IconData icon;

  /// Frase curta em destaque.
  final String title;

  /// Explicação do que aconteceu ou do que o usuário pode fazer.
  final String message;

  /// Cor do ícone (azul por padrão, amarelo para alertas, vermelho para erro).
  final Color iconColor;

  /// Botão opcional exibido no fim, por exemplo "Tentar novamente".
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.spaceL,
        vertical: AppMetrics.spaceXL,
      ),
      child: Column(
        // Ocupa só a altura necessária para o conteúdo.
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppMetrics.iconXL, color: iconColor),
          const SizedBox(height: AppMetrics.spaceL),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppMetrics.spaceS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          // O botão de ação só aparece quando foi informado.
          if (action != null) ...[
            const SizedBox(height: AppMetrics.spaceL),
            action!,
          ],
        ],
      ),
    );
  }
}
