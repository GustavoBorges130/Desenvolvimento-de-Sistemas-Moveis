// =============================================================================
// Passo 05 do desafio - módulo Home, diretório components.
// Resultado esperado: "componente com campos para consulta de CEP".
// Também atende à busca de CEP por endereço completo ou parcial.
// =============================================================================

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../service/address_service.dart';

/// Tipo de consulta escolhida no formulário.
enum SearchType { cep, address }

/// Dados preenchidos no formulário de nova consulta.
///
/// Tem dois construtores, um para cada tipo de consulta, para não misturar
/// os campos de uma com os da outra.
class AddressSearchRequest {
  /// Consulta do endereço de um CEP.
  const AddressSearchRequest.byCep(this.cep)
      : type = SearchType.cep,
        uf = '',
        city = '',
        street = '';

  /// Busca do CEP de um endereço (UF, cidade e logradouro).
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
///
/// O componente só coleta os dados; quem faz a consulta é o controller,
/// chamado pela HomePage.
class SearchAddressComponent extends StatefulWidget {
  const SearchAddressComponent({super.key});

  /// Abre o formulário e retorna o que foi preenchido (ou `null` se o
  /// usuário fechar sem consultar).
  static Future<AddressSearchRequest?> show(BuildContext context) {
    return showModalBottomSheet<AddressSearchRequest>(
      context: context,
      // Permite que o formulário suba junto com o teclado.
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
  /// Chave do formulário, usada para validar todos os campos de uma vez.
  final _formKey = GlobalKey<FormState>();

  // Controladores que guardam o texto digitado em cada campo.
  final _cepController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();

  /// Aba selecionada: "Por CEP" ou "Por endereço".
  SearchType _type = SearchType.cep;

  /// UF escolhida na lista.
  String? _uf;

  @override
  void dispose() {
    // Libera os controladores de texto ao fechar o formulário.
    _cepController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  /// Valida o formulário e devolve os dados para a HomePage.
  void _submit() {
    // validate() executa o `validator` de cada campo; se algum devolver
    // uma mensagem, ela aparece embaixo do campo e a consulta não segue.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = _type == SearchType.cep
        ? AddressSearchRequest.byCep(_cepController.text)
        : AddressSearchRequest.byAddress(
            uf: _uf ?? '',
            city: _cityController.text,
            street: _streetController.text,
          );

    // Fecha o bottom sheet devolvendo os dados preenchidos.
    Navigator.of(context).pop(request);
  }

  /// O CEP precisa ter 8 números (a máscara já impede letras).
  String? _validateCep(String? value) {
    if (AddressService.isValidCep(value ?? '')) return null;
    return 'Digite os 8 números do CEP';
  }

  /// Cidade e logradouro precisam de pelo menos 3 letras (regra da ViaCEP).
  String? _validateMinLength(String? value, String field) {
    final text = (value ?? '').trim();
    if (text.length >= AddressService.minSearchLength) return null;
    return 'Informe $field (mínimo ${AddressService.minSearchLength} letras)';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Altura do teclado aberto; usada para o formulário não ficar escondido.
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
              // Título e explicação, que muda conforme a aba escolhida.
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

              // Abas para escolher o tipo de consulta.
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
                  // setState redesenha o formulário com os campos da aba.
                  setState(() => _type = selection.first);
                },
              ),
              const SizedBox(height: AppMetrics.spaceL),

              if (_type == SearchType.cep)
                // ----- Consulta por CEP -----
                TextFormField(
                  key: const Key('cepField'),
                  controller: _cepController,
                  autofocus: true,
                  // Abre o teclado numérico.
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.search,
                  // Aplica a máscara 00000-000 enquanto digita.
                  inputFormatters: [CepInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'CEP',
                    hintText: '00000-000',
                    prefixIcon: Icon(Icons.pin_drop_outlined),
                  ),
                  validator: _validateCep,
                  // Botão "pesquisar" do teclado também envia o formulário.
                  onFieldSubmitted: (_) => _submit(),
                )
              else ...[
                // ----- Busca por endereço -----
                // Lista com as 27 UFs.
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
                  // Primeira letra de cada palavra em maiúscula.
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

              // Botão que valida e envia o formulário.
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
///
/// Um TextInputFormatter recebe o texto antigo e o novo a cada tecla e
/// devolve o texto que deve aparecer no campo.
class CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Mantém só os números e no máximo 8 dígitos.
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    // Coloca o hífen depois do 5º dígito.
    final text = digits.length > 5
        ? '${digits.substring(0, 5)}-${digits.substring(5)}'
        : digits;

    // Deixa o cursor no fim do texto.
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
