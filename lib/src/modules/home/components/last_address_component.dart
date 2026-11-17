import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Cartão com os dados do último endereço consultado e a ação de traçar a
/// rota até ele.
class LastAddressComponent extends StatelessWidget {
  const LastAddressComponent({
    super.key,
    required this.address,
    required this.onTraceRoute,
  });

  final AddressModel address;
  final VoidCallback onTraceRoute;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppMetrics.spaceM,
                    vertical: AppMetrics.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(AppMetrics.radiusL),
                  ),
                  child: Text(
                    'CEP ${address.formattedCep}',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                if (address.formattedConsultedAt.isNotEmpty)
                  Flexible(
                    child: Text(
                      address.formattedConsultedAt,
                      textAlign: TextAlign.end,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppMetrics.spaceL),
            Text(
              address.streetLine,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (address.bairro.isNotEmpty) ...[
              const SizedBox(height: AppMetrics.spaceXS),
              Text(
                address.bairro,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppMetrics.spaceXS),
            Text(
              address.estado.isEmpty
                  ? address.cityLine
                  : '${address.cityLine} (${address.estado})',
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppMetrics.spaceL),
            Wrap(
              spacing: AppMetrics.spaceS,
              runSpacing: AppMetrics.spaceS,
              children: [
                if (address.ddd.isNotEmpty)
                  _InfoChip(label: 'DDD', value: address.ddd),
                if (address.ibge.isNotEmpty)
                  _InfoChip(label: 'IBGE', value: address.ibge),
                if (address.regiao.isNotEmpty)
                  _InfoChip(label: 'Região', value: address.regiao),
              ],
            ),
            const SizedBox(height: AppMetrics.spaceL),
            FilledButton.icon(
              onPressed: onTraceRoute,
              icon: const Icon(Icons.directions),
              label: const Text('Traçar rota'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppMetrics.spaceS,
        vertical: AppMetrics.spaceXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppMetrics.radiusS),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
