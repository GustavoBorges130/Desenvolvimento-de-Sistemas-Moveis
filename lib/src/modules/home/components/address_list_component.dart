import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Lista de endereços consultados.
///
/// Usada na home (consultas recentes), na escolha de resultados da busca por
/// endereço e na tela de histórico.
class AddressListComponent extends StatelessWidget {
  const AddressListComponent({
    super.key,
    required this.addresses,
    this.onTap,
    this.showConsultedAt = true,
    this.scrollable = false,
    this.padding = EdgeInsets.zero,
  });

  final List<AddressModel> addresses;
  final ValueChanged<AddressModel>? onTap;

  /// Exibe a data/hora em que cada endereço foi consultado.
  final bool showConsultedAt;

  /// Quando `false`, a lista ocupa só a altura dos itens e pode ficar dentro
  /// de outra área rolável (como na home).
  final bool scrollable;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: !scrollable,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: addresses.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppMetrics.spaceS),
      itemBuilder: (context, index) {
        final address = addresses[index];
        return _AddressListItem(
          address: address,
          showConsultedAt: showConsultedAt,
          onTap: onTap == null ? null : () => onTap!(address),
        );
      },
    );
  }
}

class _AddressListItem extends StatelessWidget {
  const _AddressListItem({
    required this.address,
    required this.showConsultedAt,
    this.onTap,
  });

  final AddressModel address;
  final bool showConsultedAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final details = [address.bairro, address.cityLine]
        .where((value) => value.isNotEmpty)
        .join(' • ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.spaceM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppMetrics.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppMetrics.radiusS),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppMetrics.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.streetLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: AppMetrics.spaceXS),
                    Wrap(
                      spacing: AppMetrics.spaceS,
                      runSpacing: AppMetrics.spaceXXS,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'CEP ${address.formattedCep}',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (showConsultedAt &&
                            address.formattedConsultedAt.isNotEmpty)
                          Text(
                            address.formattedConsultedAt,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
