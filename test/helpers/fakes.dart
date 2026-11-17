// Dublês (fakes) usados nos testes: substituem a API ViaCEP, o Hive e o
// geocoding por versões em memória, para os testes rodarem sem internet e
// com resultados previsíveis.

import 'package:fast_location/src/modules/home/model/address_exceptions.dart';
import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:fast_location/src/modules/home/repositories/address_local_repository.dart';
import 'package:fast_location/src/modules/home/repositories/address_repository.dart';
import 'package:fast_location/src/modules/home/repositories/location_repository.dart';
import 'package:geocoding/geocoding.dart';

const pracaDaSe = AddressModel(
  cep: '01001-000',
  logradouro: 'Praça da Sé',
  complemento: 'lado ímpar',
  bairro: 'Sé',
  localidade: 'São Paulo',
  uf: 'SP',
  estado: 'São Paulo',
  regiao: 'Sudeste',
  ibge: '3550308',
  gia: '1004',
  ddd: '11',
  siafi: '7107',
);

const felipeSchmidt = AddressModel(
  cep: '88010-001',
  logradouro: 'Rua Felipe Schmidt',
  complemento: 'até 389/390',
  bairro: 'Centro',
  localidade: 'Florianópolis',
  uf: 'SC',
  ddd: '48',
);

const felipeSchmidt2 = AddressModel(
  cep: '88010-002',
  logradouro: 'Rua Felipe Schmidt',
  complemento: 'de 391/392 ao fim',
  bairro: 'Centro',
  localidade: 'Florianópolis',
  uf: 'SC',
  ddd: '48',
);

/// Simula a API ViaCEP.
class FakeAddressRepository implements AddressRepository {
  final Map<String, AddressModel> addresses = {};
  List<AddressModel> searchResult = [];
  AddressException? error;
  int getCalls = 0;
  int searchCalls = 0;
  Map<String, String>? lastSearch;

  @override
  Future<AddressModel> getAddressByCep(String cep) async {
    getCalls++;
    if (error != null) throw error!;
    final address = addresses[cep];
    if (address == null) throw const AddressNotFoundException();
    return address;
  }

  @override
  Future<List<AddressModel>> searchAddresses({
    required String uf,
    required String city,
    required String street,
  }) async {
    searchCalls++;
    lastSearch = {'uf': uf, 'city': city, 'street': street};
    if (error != null) throw error!;
    return searchResult;
  }
}

/// Armazenamento local em memória.
class FakeAddressLocalRepository implements AddressLocalRepository {
  final Map<String, AddressModel> box = {};

  @override
  Future<List<AddressModel>> getHistory() async {
    final history = box.values.toList()
      ..sort((a, b) => b.consultedAt!.compareTo(a.consultedAt!));
    return history;
  }

  @override
  Future<AddressModel?> getLastAddress() async {
    final history = await getHistory();
    return history.isEmpty ? null : history.first;
  }

  @override
  Future<AddressModel?> getByCep(String cep) async => box[cep];

  @override
  Future<void> save(AddressModel address) async {
    box[address.cepDigits] = address;
  }

  @override
  Future<void> clear() async => box.clear();
}

/// Simula o geocoding do aparelho.
class FakeLocationRepository implements LocationRepository {
  final Map<String, Location> known = {};
  final List<String> queries = [];

  @override
  Future<List<Location>> getLocations(String address) async {
    queries.add(address);
    final location = known[address];
    if (location == null) throw Exception('Endereço não reconhecido');
    return [location];
  }
}

Location fakeLocation(double latitude, double longitude) => Location(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime(2026),
    );

/// Relógio controlável para os testes.
class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance([Duration duration = const Duration(minutes: 1)]) {
    now = now.add(duration);
  }
}
