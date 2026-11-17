// =============================================================================
// Passo 05 do desafio - módulo Home, diretório model:
// "criar classe para definir estrutura de dados para retorno da consulta da
// api externa (https://viacep.com.br/ws)".
// =============================================================================

import 'package:hive/hive.dart';

import '../../../shared/storage/storage_keys.dart';

// Arquivo gerado pelo hive_generator (comando build_runner) com o
// AddressModelAdapter, que sabe gravar e ler esta classe no Hive.
part 'address_model.g.dart';

/// Estrutura de dados retornada pela API ViaCEP (https://viacep.com.br/ws).
///
/// Exemplo de retorno de `GET /ws/01001000/json/`:
///
/// ```json
/// {
///   "cep": "01001-000",
///   "logradouro": "Praça da Sé",
///   "complemento": "lado ímpar",
///   "unidade": "",
///   "bairro": "Sé",
///   "localidade": "São Paulo",
///   "uf": "SP",
///   "estado": "São Paulo",
///   "regiao": "Sudeste",
///   "ibge": "3550308",
///   "gia": "1004",
///   "ddd": "11",
///   "siafi": "7107"
/// }
/// ```
///
/// A classe também é persistida no Hive (histórico de consultas). Por isso,
/// além dos campos da API, guarda a data em que o endereço foi consultado.
///
/// `@HiveType` marca a classe para o hive_generator e `@HiveField(n)` marca
/// cada campo gravado. O número de cada campo não pode mudar depois que o
/// app estiver em uso, senão os dados já salvos deixam de ser lidos.
@HiveType(typeId: HiveTypeIds.address)
class AddressModel {
  const AddressModel({
    required this.cep,
    this.logradouro = '',
    this.complemento = '',
    this.unidade = '',
    this.bairro = '',
    this.localidade = '',
    this.uf = '',
    this.estado = '',
    this.regiao = '',
    this.ibge = '',
    this.gia = '',
    this.ddd = '',
    this.siafi = '',
    this.consultedAt,
  });

  /// Cria o modelo a partir do JSON devolvido pela ViaCEP.
  ///
  /// Campos ausentes ou nulos viram texto vazio, então o restante do app
  /// não precisa tratar `null` em cada campo.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Função auxiliar: lê a chave, troca null por '' e remove espaços.
    String read(String key) => (json[key] ?? '').toString().trim();

    return AddressModel(
      cep: read('cep'),
      logradouro: read('logradouro'),
      complemento: read('complemento'),
      unidade: read('unidade'),
      bairro: read('bairro'),
      localidade: read('localidade'),
      uf: read('uf'),
      estado: read('estado'),
      regiao: read('regiao'),
      ibge: read('ibge'),
      gia: read('gia'),
      ddd: read('ddd'),
      siafi: read('siafi'),
    );
  }

  // ---------------------------------------------------------------------------
  // Campos da API ViaCEP
  // `defaultValue` é usado pelo adapter quando o campo não existe no registro
  // salvo (por exemplo, dados gravados por uma versão anterior do app).
  // ---------------------------------------------------------------------------

  /// CEP no formato devolvido pela API (ex.: 01001-000).
  @HiveField(0, defaultValue: '')
  final String cep;

  /// Rua, avenida, praça etc.
  @HiveField(1, defaultValue: '')
  final String logradouro;

  /// Complemento do CEP (ex.: "lado ímpar", "até 389/390").
  @HiveField(2, defaultValue: '')
  final String complemento;

  /// Unidade dos Correios, quando o CEP é de uma agência ou caixa postal.
  @HiveField(3, defaultValue: '')
  final String unidade;

  @HiveField(4, defaultValue: '')
  final String bairro;

  /// Cidade.
  @HiveField(5, defaultValue: '')
  final String localidade;

  /// Sigla do estado (ex.: SP).
  @HiveField(6, defaultValue: '')
  final String uf;

  /// Nome do estado (ex.: São Paulo).
  @HiveField(7, defaultValue: '')
  final String estado;

  /// Região do país (ex.: Sudeste).
  @HiveField(8, defaultValue: '')
  final String regiao;

  /// Código do município no IBGE.
  @HiveField(9, defaultValue: '')
  final String ibge;

  /// Código GIA (usado em São Paulo).
  @HiveField(10, defaultValue: '')
  final String gia;

  /// DDD telefônico da cidade.
  @HiveField(11, defaultValue: '')
  final String ddd;

  /// Código do município no SIAFI.
  @HiveField(12, defaultValue: '')
  final String siafi;

  // ---------------------------------------------------------------------------
  // Campo próprio do app (não vem da API)
  // ---------------------------------------------------------------------------

  /// Momento em que o endereço foi consultado no aparelho.
  @HiveField(13)
  final DateTime? consultedAt;

  /// Converte de volta para o formato JSON da API (sem a data da consulta).
  Map<String, dynamic> toJson() => {
        'cep': cep,
        'logradouro': logradouro,
        'complemento': complemento,
        'unidade': unidade,
        'bairro': bairro,
        'localidade': localidade,
        'uf': uf,
        'estado': estado,
        'regiao': regiao,
        'ibge': ibge,
        'gia': gia,
        'ddd': ddd,
        'siafi': siafi,
      };

  /// Cria uma cópia do endereço trocando a data da consulta.
  ///
  /// Os campos são `final` (imutáveis), então para "alterar" um endereço o
  /// app cria um novo objeto com o valor desejado.
  AddressModel copyWith({DateTime? consultedAt}) {
    return AddressModel(
      cep: cep,
      logradouro: logradouro,
      complemento: complemento,
      unidade: unidade,
      bairro: bairro,
      localidade: localidade,
      uf: uf,
      estado: estado,
      regiao: regiao,
      ibge: ibge,
      gia: gia,
      ddd: ddd,
      siafi: siafi,
      consultedAt: consultedAt ?? this.consultedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Textos prontos para exibir nas telas
  // ---------------------------------------------------------------------------

  /// CEP somente com números (ex.: 01001000). Usado como chave no Hive.
  String get cepDigits => cep.replaceAll(RegExp(r'\D'), '');

  /// CEP no formato 00000-000.
  String get formattedCep {
    final digits = cepDigits;
    if (digits.length != 8) return cep;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  /// Logradouro com complemento, ou um aviso quando o CEP é de uma cidade
  /// inteira (municípios de CEP único não possuem logradouro).
  String get streetLine {
    if (logradouro.isEmpty) return 'Logradouro não informado';
    if (complemento.isEmpty) return logradouro;
    return '$logradouro, $complemento';
  }

  /// Cidade e estado no formato "Cidade - UF".
  String get cityLine => [localidade, uf].where(_isFilled).join(' - ');

  /// Endereço completo em uma linha, usado nas listas.
  String get fullAddress =>
      [logradouro, bairro, cityLine].where(_isFilled).join(', ');

  /// Data da consulta no formato dd/MM/aaaa às HH:mm.
  String get formattedConsultedAt {
    final date = consultedAt;
    if (date == null) return '';
    // Completa com zero à esquerda: 7 -> "07".
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        'às ${two(date.hour)}:${two(date.minute)}';
  }

  static bool _isFilled(String value) => value.trim().isNotEmpty;

  // ---------------------------------------------------------------------------
  // Igualdade
  // Dois endereços são iguais quando têm o mesmo CEP, logradouro e
  // complemento, mesmo que tenham sido consultados em datas diferentes.
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModel &&
          other.cepDigits == cepDigits &&
          other.logradouro == logradouro &&
          other.complemento == complemento;

  @override
  int get hashCode => Object.hash(cepDigits, logradouro, complemento);

  @override
  String toString() => 'AddressModel($formattedCep, $fullAddress)';
}
