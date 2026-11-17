// Testes do AddressModel: conversão do JSON da ViaCEP e textos exibidos
// nas telas (CEP formatado, endereço completo, data da consulta).

import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddressModel', () {
    test('converte o JSON da ViaCEP', () {
      final address = AddressModel.fromJson(const {
        'cep': '01001-000',
        'logradouro': 'Praça da Sé',
        'complemento': 'lado ímpar',
        'unidade': '',
        'bairro': 'Sé',
        'localidade': 'São Paulo',
        'uf': 'SP',
        'estado': 'São Paulo',
        'regiao': 'Sudeste',
        'ibge': '3550308',
        'gia': '1004',
        'ddd': '11',
        'siafi': '7107',
      });

      expect(address.cep, '01001-000');
      expect(address.cepDigits, '01001000');
      expect(address.formattedCep, '01001-000');
      expect(address.logradouro, 'Praça da Sé');
      expect(address.localidade, 'São Paulo');
      expect(address.uf, 'SP');
      expect(address.ddd, '11');
      expect(address.consultedAt, isNull);
    });

    test('aceita campos ausentes no JSON', () {
      final address = AddressModel.fromJson(const {
        'cep': '87365000',
        'localidade': 'Goioerê',
        'uf': 'PR',
      });

      expect(address.logradouro, isEmpty);
      expect(address.formattedCep, '87365-000');
      expect(address.streetLine, 'Logradouro não informado');
      expect(address.fullAddress, 'Goioerê - PR');
    });

    test('monta os textos exibidos nas telas', () {
      final address = AddressModel(
        cep: '01001000',
        logradouro: 'Praça da Sé',
        complemento: 'lado ímpar',
        bairro: 'Sé',
        localidade: 'São Paulo',
        uf: 'SP',
        consultedAt: DateTime(2026, 11, 7, 9, 5),
      );

      expect(address.streetLine, 'Praça da Sé, lado ímpar');
      expect(address.cityLine, 'São Paulo - SP');
      expect(address.fullAddress, 'Praça da Sé, Sé, São Paulo - SP');
      expect(address.formattedConsultedAt, '07/11/2026 às 09:05');
    });

    test('copyWith altera apenas a data da consulta', () {
      const address = AddressModel(cep: '01001-000', logradouro: 'Praça');
      final consulted = address.copyWith(consultedAt: DateTime(2026));

      expect(consulted.consultedAt, DateTime(2026));
      expect(consulted.logradouro, 'Praça');
      expect(consulted, address);
    });

    test('toJson devolve os campos da API', () {
      const address = AddressModel(cep: '01001-000', uf: 'SP');

      expect(address.toJson()['cep'], '01001-000');
      expect(address.toJson()['uf'], 'SP');
      expect(address.toJson().containsKey('consultedAt'), isFalse);
    });
  });
}
