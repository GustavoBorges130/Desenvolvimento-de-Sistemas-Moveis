import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Tela de carregamento exibida sobre o conteúdo durante consultas externas.
///
/// Bloqueia toques na tela enquanto a consulta não termina, evitando que o
/// entregador dispare a mesma busca várias vezes.
class LoadingComponent extends StatelessWidget {
  const LoadingComponent({super.key, this.message = 'Carregando...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: AppColors.overlay,
          child: Center(
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
                  const SizedBox(
                    width: AppMetrics.iconL,
                    height: AppMetrics.iconL,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: AppMetrics.spaceL),
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
