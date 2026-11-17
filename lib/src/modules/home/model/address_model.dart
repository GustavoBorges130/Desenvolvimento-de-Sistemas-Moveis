import 'package:hive/hive.dart';

import '../../../shared/storage/storage_keys.dart';

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

  factory AddressModel.fromJson(Map<String, dynamic> json) {
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

  @HiveField(0, defaultValue: '')
  final String cep;

  @HiveField(1, defaultValue: '')
  final String logradouro;

  @HiveField(2, defaultValue: '')
  final String complemento;

  @HiveField(3, defaultValue: '')
  final String unidade;

  @HiveField(4, defaultValue: '')
  final String bairro;

  @HiveField(5, defaultValue: '')
  final String localidade;

  @HiveField(6, defaultValue: '')
  final String uf;

  @HiveField(7, defaultValue: '')
  final String estado;

  @HiveField(8, defaultValue: '')
  final String regiao;

  @HiveField(9, defaultValue: '')
  final String ibge;

  @HiveField(10, defaultValue: '')
  final String gia;

  @HiveField(11, defaultValue: '')
  final String ddd;

  @HiveField(12, defaultValue: '')
  final String siafi;

  /// Momento em que o endereço foi consultado no aparelho.
  @HiveField(13)
  final DateTime? consultedAt;

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
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        'às ${two(date.hour)}:${two(date.minute)}';
  }

  static bool _isFilled(String value) => value.trim().isNotEmpty;

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
