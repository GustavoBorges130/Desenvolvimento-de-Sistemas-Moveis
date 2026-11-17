// =============================================================================
// Passo 05 do desafio - módulo Home, diretório components:
// "criar classe para definir componente de lista de endereços consultados".
// =============================================================================

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

  /// Endereços exibidos, na ordem da lista.
  final List<AddressModel> addresses;

  /// Ação ao tocar em um endereço. Se for nula, os itens não são clicáveis.
  final ValueChanged<AddressModel>? onTap;

  /// Exibe a data/hora em que cada endereço foi consultado.
  final bool showConsultedAt;

  /// Quando `false`, a lista ocupa só a altura dos itens e pode ficar dentro
  /// de outra área rolável (como na home).
  final bool scrollable;

  /// Espaçamento interno da lista.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // ListView.separated monta os itens sob demanda e coloca um espaço
    // entre eles.
    return ListView.separated(
      padding: padding,
      // shrinkWrap + NeverScrollable: a lista não rola sozinha, quem rola é
      // a tela onde ela está (usado na home).
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

/// Cartão de um endereço da lista.
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

    // Linha de detalhes: "Bairro • Cidade - UF" (só as partes preenchidas).
    final details = [address.bairro, address.cityLine]
        .where((value) => value.isNotEmpty)
        .join(' • ');

    return Card(
      // Faz o efeito de toque (InkWell) respeitar as bordas arredondadas.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppMetrics.spaceM),
          child: Row(
            children: [
              // Ícone de localização à esquerda.
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
              // Textos do endereço.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logradouro e complemento.
                    Text(
                      address.streetLine,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Bairro e cidade.
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
                    // CEP e data da consulta. Wrap quebra a linha se não
                    // couber na largura da tela.
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
              // Seta indicando que o item é clicável.
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
