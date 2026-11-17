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

  final AddressRepository _remote;
  final AddressLocalRepository _local;
  final LocationRepository _location;
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
  static String sanitizeCep(String cep) => cep.replaceAll(RegExp(r'\D'), '');

  static bool isValidCep(String cep) => sanitizeCep(cep).length == 8;

  /// Consulta o endereço de um CEP.
  ///
  /// Lança [InvalidCepException], [AddressNotFoundException] ou
  /// [AddressConnectionException].
  Future<AddressModel> getAddressByCep(String cep) async {
    final cepDigits = sanitizeCep(cep);
    if (cepDigits.length != 8) throw const InvalidCepException();

    final savedAddress = await _local.getByCep(cepDigits);
    final address = savedAddress ?? await _remote.getAddressByCep(cepDigits);

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
    final normalizedUf = uf.trim().toUpperCase();
    final normalizedCity = _normalizeSpaces(city);
    final normalizedStreet = _normalizeSpaces(street);

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

  Future<List<AddressModel>> getHistory() => _local.getHistory();

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
        if (locations.isNotEmpty) return locations.first;
      } catch (_) {
        // Endereço não reconhecido nesse formato: tenta o próximo.
      }
    }

    throw const AddressLocationException();
  }

  /// Textos usados na geocodificação, do mais preciso ao mais genérico.
  static List<String> buildGeocodingQueries(AddressModel address) {
    String join(List<String> parts) =>
        [...parts.where((part) => part.trim().isNotEmpty), 'Brasil']
            .join(', ');

    final queries = <String>[
      if (address.logradouro.isNotEmpty)
        join([address.logradouro, address.bairro, address.cityLine]),
      join([address.formattedCep, address.cityLine]),
      if (address.cityLine.isNotEmpty) join([address.cityLine]),
    ];

    return queries.toSet().toList();
  }

  static String _normalizeSpaces(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
