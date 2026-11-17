// Testes do AddressRepository (API ViaCEP). O Dio usa um adaptador falso,
// que responde sem acessar a internet, para simular cada retorno da API.

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fast_location/src/http/dio_client.dart';
import 'package:fast_location/src/modules/home/model/address_exceptions.dart';
import 'package:fast_location/src/modules/home/repositories/address_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Adapter HTTP que responde sem acessar a rede.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;
  final List<Uri> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.uri);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: ['application/json; charset=utf-8'],
    },
  );
}

void main() {
  late Dio dio;
  late _FakeAdapter adapter;
  late AddressRepository repository;

  void respond(ResponseBody Function(RequestOptions options) handler) {
    adapter = _FakeAdapter(handler);
    dio = DioClient.create()..httpClientAdapter = adapter;
    dio.interceptors.clear();
    repository = AddressRepository(dio: dio);
  }

  group('AddressRepository.getAddressByCep', () {
    test('consulta /ws/{cep}/json/ e converte o retorno', () async {
      respond((_) => _json({
            'cep': '01001-000',
            'logradouro': 'Praça da Sé',
            'localidade': 'São Paulo',
            'uf': 'SP',
          }));

      final address = await repository.getAddressByCep('01001000');

      expect(
        adapter.requests.single.toString(),
        'https://viacep.com.br/ws/01001000/json/',
      );
      expect(address.logradouro, 'Praça da Sé');
    });

    test('{"erro": true} vira AddressNotFoundException', () {
      respond((_) => _json({'erro': true}));

      expect(
        repository.getAddressByCep('99999999'),
        throwsA(isA<AddressNotFoundException>()),
      );
    });

    test('{"erro": "true"} também vira AddressNotFoundException', () {
      respond((_) => _json({'erro': 'true'}));

      expect(
        repository.getAddressByCep('99999999'),
        throwsA(isA<AddressNotFoundException>()),
      );
    });

    test('HTTP 400 vira InvalidCepException', () {
      respond((_) => _json({'message': 'bad request'}, status: 400));

      expect(
        repository.getAddressByCep('123'),
        throwsA(isA<InvalidCepException>()),
      );
    });

    test('falha de rede vira AddressConnectionException', () {
      respond((options) => throw DioError(requestOptions: options));

      expect(
        repository.getAddressByCep('01001000'),
        throwsA(isA<AddressConnectionException>()),
      );
    });
  });

  group('AddressRepository.searchAddresses', () {
    test('codifica a URL e converte a lista', () async {
      respond((_) => _json([
            {'cep': '88010-001', 'logradouro': 'Rua Felipe Schmidt'},
            {'cep': '88010-002', 'logradouro': 'Rua Felipe Schmidt'},
          ]));

      final results = await repository.searchAddresses(
        uf: 'SC',
        city: 'Florianópolis',
        street: 'Felipe Schmidt',
      );

      expect(
        adapter.requests.single.toString(),
        'https://viacep.com.br/ws/SC/Florian%C3%B3polis/Felipe%20Schmidt/json/',
      );
      expect(results.map((a) => a.cep), ['88010-001', '88010-002']);
    });

    test('lista vazia quando nada é encontrado', () async {
      respond((_) => _json([]));

      final results = await repository.searchAddresses(
        uf: 'SC',
        city: 'Florianópolis',
        street: 'Rua que não existe',
      );

      expect(results, isEmpty);
    });

    test('HTTP 400 vira InvalidAddressSearchException', () {
      respond((_) => _json({}, status: 400));

      expect(
        repository.searchAddresses(uf: 'SC', city: 'Fl', street: 'Ru'),
        throwsA(isA<InvalidAddressSearchException>()),
      );
    });
  });
}
