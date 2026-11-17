import 'package:fast_location/src/modules/home/controller/home_controller.dart';
import 'package:fast_location/src/modules/home/model/address_exceptions.dart';
import 'package:fast_location/src/modules/home/service/address_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobx/mobx.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeAddressRepository remote;
  late FakeAddressLocalRepository local;
  late FakeLocationRepository location;
  late FakeClock clock;
  late HomeController controller;

  setUp(() {
    remote = FakeAddressRepository()
      ..addresses['01001000'] = pracaDaSe
      ..addresses['88010001'] = felipeSchmidt;
    local = FakeAddressLocalRepository();
    location = FakeLocationRepository();
    clock = FakeClock(DateTime(2026, 11, 17, 8));
    controller = HomeController(
      AddressService(
        remoteRepository: remote,
        localRepository: local,
        locationRepository: location,
        clock: () {
          clock.advance();
          return clock.now;
        },
      ),
    );
  });

  test('começa mostrando a busca vazia', () async {
    await controller.loadData();

    expect(controller.lastAddress, isNull);
    expect(controller.showEmptySearch, isTrue);
    expect(controller.hasRecentAddresses, isFalse);
  });

  test('consulta por CEP mostra o endereço e atualiza o histórico', () async {
    final loadingStates = <bool>[];
    final dispose = reaction<bool>(
      (_) => controller.isLoading,
      loadingStates.add,
    );

    await controller.searchByCep('01001-000');
    dispose();

    expect(loadingStates, [true, false]);
    expect(controller.lastAddress!.cepDigits, '01001000');
    expect(controller.showEmptySearch, isFalse);
    expect(controller.history, hasLength(1));
    // O último endereço já aparece em destaque, não nas recentes.
    expect(controller.recentAddresses, isEmpty);
  });

  test('consultas anteriores aparecem como recentes', () async {
    await controller.searchByCep('01001000');
    await controller.searchByCep('88010001');

    expect(controller.lastAddress!.cepDigits, '88010001');
    expect(controller.recentAddresses.map((a) => a.cepDigits), ['01001000']);
  });

  test('CEP inexistente mostra o componente de não encontrado', () async {
    await controller.searchByCep('99999999');

    expect(controller.notFoundMessage, isNotNull);
    expect(controller.showEmptySearch, isTrue);
    expect(controller.errorMessage, isNull);
  });

  test('erro de conexão dispara a reação de erro', () async {
    final errors = <String?>[];
    final dispose = reaction<String?>(
      (_) => controller.errorMessage,
      errors.add,
    );
    remote.error = const AddressConnectionException();

    await controller.searchByCep('01001000');
    dispose();

    expect(errors, [const AddressConnectionException().message]);
    expect(controller.isLoading, isFalse);
  });

  test('busca por endereço com vários resultados aguarda escolha', () async {
    remote.searchResult = [felipeSchmidt, felipeSchmidt2];

    await controller.searchByAddress(
      uf: 'SC',
      city: 'Florianópolis',
      street: 'Felipe Schmidt',
    );

    expect(controller.searchResults, hasLength(2));
    expect(controller.lastAddress, isNull);

    await controller.selectAddress(felipeSchmidt2);

    expect(controller.searchResults, isNull);
    expect(controller.lastAddress!.cepDigits, '88010002');
    expect(local.box.containsKey('88010002'), isTrue);
  });

  test('busca por endereço com um resultado já mostra o endereço', () async {
    remote.searchResult = [felipeSchmidt];

    await controller.searchByAddress(
      uf: 'SC',
      city: 'Florianópolis',
      street: 'Felipe Schmidt',
    );

    expect(controller.searchResults, isNull);
    expect(controller.lastAddress!.cepDigits, '88010001');
  });

  test('busca por endereço sem resultados mostra não encontrado', () async {
    remote.searchResult = [];

    await controller.searchByAddress(
      uf: 'SC',
      city: 'Florianópolis',
      street: 'Rua Inexistente',
    );

    expect(controller.notFoundMessage, contains('Rua Inexistente'));
  });

  test('rota sem endereço consultado gera erro', () async {
    final location = await controller.getLastAddressLocation();

    expect(location, isNull);
    expect(controller.errorMessage, isNotNull);
  });

  test('rota devolve as coordenadas do último endereço', () async {
    location.known['Praça da Sé, Sé, São Paulo - SP, Brasil'] =
        fakeLocation(-23.55, -46.63);
    await controller.searchByCep('01001000');

    final coordinates = await controller.getLastAddressLocation();

    expect(coordinates!.longitude, -46.63);
    expect(controller.isLoading, isFalse);
  });
}
