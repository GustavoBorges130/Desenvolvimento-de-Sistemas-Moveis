import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Bloco com ícone, título e texto de apoio, usado para estados vazios,
/// avisos e resultados não encontrados.
class MessageComponent extends StatelessWidget {
  const MessageComponent({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.primary,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
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
          if (action != null) ...[
            const SizedBox(height: AppMetrics.spaceL),
            action!,
          ],
        ],
      ),
    );
  }
}
