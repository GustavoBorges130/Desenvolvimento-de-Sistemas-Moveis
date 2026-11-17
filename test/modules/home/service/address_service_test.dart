// Testes das regras de negócio do AddressService: validação do CEP e da
// busca por endereço, consultas recorrentes lidas do armazenamento local e
// conversão do endereço em coordenadas para a rota.

import 'package:fast_location/src/modules/home/model/address_exceptions.dart';
import 'package:fast_location/src/modules/home/service/address_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeAddressRepository remote;
  late FakeAddressLocalRepository local;
  late FakeLocationRepository location;
  late FakeClock clock;
  late AddressService service;

  setUp(() {
    remote = FakeAddressRepository()..addresses['01001000'] = pracaDaSe;
    local = FakeAddressLocalRepository();
    location = FakeLocationRepository();
    clock = FakeClock(DateTime(2026, 11, 17, 8));
    service = AddressService(
      remoteRepository: remote,
      localRepository: local,
      locationRepository: location,
      clock: clock.call,
    );
  });

  group('CEP', () {
    test('sanitizeCep mantém apenas números', () {
      expect(AddressService.sanitizeCep('01001-000'), '01001000');
      expect(AddressService.sanitizeCep(' 01.001 000 '), '01001000');
      expect(AddressService.isValidCep('01001-000'), isTrue);
      expect(AddressService.isValidCep('0100100'), isFalse);
    });

    test('CEP inválido não chega a consultar a API', () {
      expect(
        service.getAddressByCep('123'),
        throwsA(isA<InvalidCepException>()),
      );
      expect(remote.getCalls, 0);
    });

    test('primeira consulta vem da API e entra no histórico', () async {
      final address = await service.getAddressByCep('01001-000');

      expect(remote.getCalls, 1);
      expect(address.logradouro, 'Praça da Sé');
      expect(address.consultedAt, clock.now);
      expect(local.box['01001000'], isNotNull);
    });

    test('consulta recorrente vem do armazenamento local', () async {
      await service.getAddressByCep('01001000');
      clock.advance(const Duration(hours: 1));

      final again = await service.getAddressByCep('01001-000');

      expect(remote.getCalls, 1, reason: 'não deve chamar a API de novo');
      expect(again.consultedAt, clock.now);
    });

    test('repassa o erro de CEP não encontrado', () {
      expect(
        service.getAddressByCep('99999-999'),
        throwsA(isA<AddressNotFoundException>()),
      );
    });
  });

  group('Busca por endereço', () {
    test('normaliza os campos antes de consultar', () async {
      remote.searchResult = [felipeSchmidt, felipeSchmidt2];

      final results = await service.searchAddresses(
        uf: 'sc',
        city: '  Florianópolis ',
        street: 'Felipe   Schmidt',
      );

      expect(results, hasLength(2));
      expect(remote.lastSearch, {
        'uf': 'SC',
        'city': 'Florianópolis',
        'street': 'Felipe Schmidt',
      });
    });

    test('valida UF, cidade e logradouro', () {
      expect(
        service.searchAddresses(uf: 'XX', city: 'Lages', street: 'Rua A'),
        throwsA(isA<InvalidAddressSearchException>()),
      );
      expect(
        service.searchAddresses(uf: 'SC', city: 'La', street: 'Rua A'),
        throwsA(isA<InvalidAddressSearchException>()),
      );
      expect(
        service.searchAddresses(uf: 'SC', city: 'Lages', street: 'Ru'),
        throwsA(isA<InvalidAddressSearchException>()),
      );
    });
  });

  group('Coordenadas para a rota', () {
    test('monta as buscas do endereço mais preciso ao mais genérico', () {
      expect(AddressService.buildGeocodingQueries(pracaDaSe), [
        'Praça da Sé, Sé, São Paulo - SP, Brasil',
        '01001-000, São Paulo - SP, Brasil',
        'São Paulo - SP, Brasil',
      ]);
    });

    test('usa o primeiro formato reconhecido', () async {
      location.known['01001-000, São Paulo - SP, Brasil'] =
          fakeLocation(-23.55, -46.63);

      final coordinates = await service.getCoordinates(pracaDaSe);

      expect(coordinates.latitude, -23.55);
      expect(location.queries, hasLength(2));
    });

    test('lança AddressLocationException se nada for reconhecido', () {
      expect(
        service.getCoordinates(pracaDaSe),
        throwsA(isA<AddressLocationException>()),
      );
    });
  });
}
