// =============================================================================
// Passo 03 do desafio - shared/components:
// componente compartilhado entre os módulos do aplicativo.
// Resultado esperado: "tela de loading para apresentar durante a consulta
// externa".
// =============================================================================

import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Tela de carregamento exibida sobre o conteúdo durante consultas externas.
///
/// Bloqueia toques na tela enquanto a consulta não termina, evitando que o
/// entregador dispare a mesma busca várias vezes.
///
/// Deve ser usado dentro de um `Stack`, pois ocupa toda a área com
/// `Positioned.fill`.
class LoadingComponent extends StatelessWidget {
  const LoadingComponent({super.key, this.message = 'Carregando...'});

  /// Texto exibido abaixo do indicador de progresso.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      // AbsorbPointer "engole" os toques: nada atrás do loading responde.
      child: AbsorbPointer(
        // Fundo escuro semitransparente cobrindo a tela inteira.
        child: Material(
          key: const Key('loadingComponent'),
          color: AppColors.overlay,
          child: Center(
            // Caixa branca central com o indicador e a mensagem.
            child: Container(
              margin: const EdgeInsets.all(AppMetrics.spaceXXL),
              padding: const EdgeInsets.symmetric(
                horizontal: AppMetrics.spaceXL,
                vertical: AppMetrics.spaceXL,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppMetrics.radiusL),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador circular girando na cor de destaque.
                  const SizedBox(
                    width: AppMetrics.iconL,
                    height: AppMetrics.iconL,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: AppMetrics.spaceL),
                  // Mensagem, por exemplo "Consultando CEP...".
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
