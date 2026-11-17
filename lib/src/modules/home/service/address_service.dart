// =============================================================================
// Passo 05 do desafio - módulo Home, diretório service:
// "criar classe para implementar as regras de negócio e obter dados dos
// repositórios previamente implementados".
// =============================================================================

import 'package:geocoding/geocoding.dart';

import '../model/address_exceptions.dart';
import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/address_repository.dart';
import '../repositories/location_repository.dart';

/// Regras de negócio das consultas de endereço.
///
/// Reúne os repositórios (API ViaCEP, armazenamento local e geocodificação)
/// e decide de onde cada informação deve vir:
/// * CEPs já consultados são lidos do armazenamento local, o que deixa as
///   consultas recorrentes instantâneas e disponíveis mesmo sem internet;
/// * toda consulta concluída entra no histórico com a data/hora atual.
///
/// O controller da tela conversa apenas com esta classe, nunca direto com
/// os repositórios.
class AddressService {
  AddressService({
    required AddressRepository remoteRepository,
    required AddressLocalRepository localRepository,
    required LocationRepository locationRepository,
    DateTime Function()? clock,
  })  : _remote = remoteRepository,
        _local = localRepository,
        _location = locationRepository,
        _clock = clock ?? DateTime.now;

  /// API ViaCEP.
  final AddressRepository _remote;

  /// Histórico salvo no aparelho (Hive).
  final AddressLocalRepository _local;

  /// Geocodificação (endereço -> coordenadas).
  final LocationRepository _location;

  /// Fornece a data/hora atual. No app é `DateTime.now`; nos testes é
  /// trocado por um relógio controlado, para as datas serem previsíveis.
  final DateTime Function() _clock;

  /// Siglas aceitas pela busca por endereço.
  static const List<String> ufs = [
    'AC', 'AL', 'AM', 'AP', 'BA', 'CE', 'DF', 'ES', 'GO', //
    'MA', 'MG', 'MS', 'MT', 'PA', 'PB', 'PE', 'PI', 'PR', //
    'RJ', 'RN', 'RO', 'RR', 'RS', 'SC', 'SE', 'SP', 'TO', //
  ];

  /// Tamanho mínimo exigido pela ViaCEP para cidade e logradouro.
  static const int minSearchLength = 3;

  /// Remove tudo o que não for número do CEP digitado.
  /// Ex.: "01001-000" -> "01001000".
  static String sanitizeCep(String cep) => cep.replaceAll(RegExp(r'\D'), '');

  /// Um CEP é válido quando tem exatamente 8 números.
  static bool isValidCep(String cep) => sanitizeCep(cep).length == 8;

  /// Consulta o endereço de um CEP.
  ///
  /// Lança [InvalidCepException], [AddressNotFoundException] ou
  /// [AddressConnectionException].
  Future<AddressModel> getAddressByCep(String cep) async {
    // 1) Valida o CEP antes de gastar uma chamada à API.
    final cepDigits = sanitizeCep(cep);
    if (cepDigits.length != 8) throw const InvalidCepException();

    // 2) Consulta recorrente: se o CEP já está no histórico, usa o dado
    //    salvo no aparelho. Só chama a API quando ainda não existe.
    final savedAddress = await _local.getByCep(cepDigits);
    final address = savedAddress ?? await _remote.getAddressByCep(cepDigits);

    // 3) Registra a consulta no histórico com a data de agora.
    return registerConsult(address);
  }

  /// Busca CEPs por endereço completo ou parcial.
  ///
  /// Retorna uma lista vazia quando nada é encontrado.
  Future<List<AddressModel>> searchAddresses({
    required String uf,
    required String city,
    required String street,
  }) async {
    // Padroniza os dados digitados: UF em maiúsculas e sem espaços
    // repetidos na cidade e no logradouro.
    final normalizedUf = uf.trim().toUpperCase();
    final normalizedCity = _normalizeSpaces(city);
    final normalizedStreet = _normalizeSpaces(street);

    // Regras da própria ViaCEP: UF válida e pelo menos 3 letras na cidade
    // e no logradouro. Validar aqui evita uma chamada que daria erro 400.
    if (!ufs.contains(normalizedUf)) {
      throw const InvalidAddressSearchException('Selecione a UF do endereço.');
    }
    if (normalizedCity.length < minSearchLength) {
      throw const InvalidAddressSearchException(
        'Informe a cidade com pelo menos $minSearchLength letras.',
      );
    }
    if (normalizedStreet.length < minSearchLength) {
      throw const InvalidAddressSearchException(
        'Informe o logradouro com pelo menos $minSearchLength letras.',
      );
    }

    return _remote.searchAddresses(
      uf: normalizedUf,
      city: normalizedCity,
      street: normalizedStreet,
    );
  }

  /// Registra o [address] no histórico como a consulta mais recente.
  Future<AddressModel> registerConsult(AddressModel address) async {
    final consulted = address.copyWith(consultedAt: _clock());
    await _local.save(consulted);
    return consulted;
  }

  /// Histórico salvo no aparelho, do mais recente para o mais antigo.
  Future<List<AddressModel>> getHistory() => _local.getHistory();

  /// Último endereço consultado, ou `null` se ainda não houve consultas.
  Future<AddressModel?> getLastAddress() => _local.getLastAddress();

  /// Converte o endereço em coordenadas para traçar a rota.
  ///
  /// Tenta do mais específico (logradouro e bairro) para o mais genérico
  /// (CEP e depois só a cidade), porque nem todo endereço da ViaCEP é
  /// reconhecido pelo serviço de mapas do aparelho.
  Future<Location> getCoordinates(AddressModel address) async {
    for (final query in buildGeocodingQueries(address)) {
      try {
        final locations = await _location.getLocations(query);
        // Encontrou: devolve a primeira coordenada e encerra a busca.
        if (locations.isNotEmpty) return locations.first;
      } catch (_) {
        // Endereço não reconhecido nesse formato: tenta o próximo.
      }
    }

    // Nenhum formato foi reconhecido.
    throw const AddressLocationException();
  }

  /// Textos usados na geocodificação, do mais preciso ao mais genérico.
  ///
  /// Ex. para a Praça da Sé:
  /// 1. "Praça da Sé, Sé, São Paulo - SP, Brasil"
  /// 2. "01001-000, São Paulo - SP, Brasil"
  /// 3. "São Paulo - SP, Brasil"
  static List<String> buildGeocodingQueries(AddressModel address) {
    // Junta as partes preenchidas e acrescenta "Brasil" no fim.
    String join(List<String> parts) =>
        [...parts.where((part) => part.trim().isNotEmpty), 'Brasil']
            .join(', ');

    final queries = <String>[
      if (address.logradouro.isNotEmpty)
        join([address.logradouro, address.bairro, address.cityLine]),
      join([address.formattedCep, address.cityLine]),
      if (address.cityLine.isNotEmpty) join([address.cityLine]),
    ];

    // toSet() remove textos repetidos mantendo a ordem.
    return queries.toSet().toList();
  }

  /// Remove espaços nas pontas e troca espaços repetidos por um só.
  static String _normalizeSpaces(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
