import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../service/address_service.dart';

/// Tipo de consulta escolhida no formulário.
enum SearchType { cep, address }

/// Dados preenchidos no formulário de nova consulta.
class AddressSearchRequest {
  const AddressSearchRequest.byCep(this.cep)
      : type = SearchType.cep,
        uf = '',
        city = '',
        street = '';

  const AddressSearchRequest.byAddress({
    required this.uf,
    required this.city,
    required this.street,
  })  : type = SearchType.address,
        cep = '';

  final SearchType type;
  final String cep;
  final String uf;
  final String city;
  final String street;
}

/// Formulário de nova consulta, exibido em um bottom sheet.
///
/// Permite consultar o endereço de um CEP ou buscar o CEP de um endereço
/// completo ou parcial (UF, cidade e logradouro). Ao confirmar, fecha o
/// bottom sheet devolvendo um [AddressSearchRequest].
class SearchAddressComponent extends StatefulWidget {
  const SearchAddressComponent({super.key});

  /// Abre o formulário e retorna o que foi preenchido (ou `null` se o
  /// usuário fechar sem consultar).
  static Future<AddressSearchRequest?> show(BuildContext context) {
    return showModalBottomSheet<AddressSearchRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (_) => const SearchAddressComponent(),
    );
  }

  @override
  State<SearchAddressComponent> createState() => _SearchAddressComponentState();
}

class _SearchAddressComponentState extends State<SearchAddressComponent> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();

  SearchType _type = SearchType.cep;
  String? _uf;

  @override
  void dispose() {
    _cepController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = _type == SearchType.cep
        ? AddressSearchRequest.byCep(_cepController.text)
        : AddressSearchRequest.byAddress(
            uf: _uf ?? '',
            city: _cityController.text,
            street: _streetController.text,
          );

    Navigator.of(context).pop(request);
  }

  String? _validateCep(String? value) {
    if (AddressService.isValidCep(value ?? '')) return null;
    return 'Digite os 8 números do CEP';
  }

  String? _validateMinLength(String? value, String field) {
    final text = (value ?? '').trim();
    if (text.length >= AddressService.minSearchLength) return null;
    return 'Informe $field (mínimo ${AddressService.minSearchLength} letras)';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppMetrics.pagePadding,
        0,
        AppMetrics.pagePadding,
        AppMetrics.spaceXL + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nova consulta',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppMetrics.spaceXS),
              Text(
                _type == SearchType.cep
                    ? 'Digite o CEP para ver o endereço completo.'
                    : 'Informe o endereço, mesmo que parcial, para descobrir '
                        'o CEP.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppMetrics.spaceL),
              SegmentedButton<SearchType>(
                segments: const [
                  ButtonSegment(
                    value: SearchType.cep,
                    icon: Icon(Icons.pin_drop_outlined),
                    label: Text('Por CEP'),
                  ),
                  ButtonSegment(
                    value: SearchType.address,
                    icon: Icon(Icons.signpost_outlined),
                    label: Text('Por endereço'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() => _type = selection.first);
                },
              ),
              const SizedBox(height: AppMetrics.spaceL),
              if (_type == SearchType.cep)
                TextFormField(
                  key: const Key('cepField'),
                  controller: _cepController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  inputFormatters: [CepInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    hintText: '00000-000',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  validator: _validateCep,
                  onFieldSubmitted: (_) => _submit(),
                )
              else ...[
                DropdownButtonFormField<String>(
                  key: const Key('ufField'),
                  initialValue: _uf,
                  decoration: const InputDecoration(
                    labelText: 'UF',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: [
                    for (final uf in AddressService.ufs)
                      DropdownMenuItem(value: uf, child: Text(uf)),
                  ],
                  onChanged: (value) => setState(() => _uf = value),
                  validator: (value) =>
                      value == null ? 'Selecione a UF' : null,
                ),
                const SizedBox(height: AppMetrics.spaceM),
                TextFormField(
                  key: const Key('cityField'),
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    hintText: 'Ex.: Florianópolis',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) => _validateMinLength(value, 'a cidade'),
                ),
                const SizedBox(height: AppMetrics.spaceM),
                TextFormField(
                  key: const Key('streetField'),
                  controller: _streetController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro',
                    hintText: 'Ex.: Rua Felipe Schmidt',
                    prefixIcon: Icon(Icons.signpost_outlined),
                  ),
                  validator: (value) =>
                      _validateMinLength(value, 'o logradouro'),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
              const SizedBox(height: AppMetrics.spaceXL),
              FilledButton.icon(
                key: const Key('searchButton'),
                onPressed: _submit,
                icon: const Icon(Icons.search),
                label: const Text('Consultar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aplica a máscara 00000-000 enquanto o CEP é digitado.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    final text = digits.length > 5
        ? '${digits.substring(0, 5)}-${digits.substring(5)}'
        : digits;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
