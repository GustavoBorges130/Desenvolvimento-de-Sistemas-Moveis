import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Título de seção usado para separar blocos de conteúdo nas telas.
class SectionTitleComponent extends StatelessWidget {
  const SectionTitleComponent({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppMetrics.spaceS),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppMetrics.iconS, color: AppColors.primary),
            const SizedBox(width: AppMetrics.spaceS),
          ],
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
