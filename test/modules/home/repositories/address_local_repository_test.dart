// Testes do AddressLocalRepository com o Hive de verdade, gravando numa
// pasta temporária. Confirmam que o adapter gerado pelo hive_generator
// salva e lê os endereços corretamente.

import 'dart:io';

import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:fast_location/src/modules/home/repositories/address_local_repository.dart';
import 'package:fast_location/src/shared/storage/hive_config.dart';
import 'package:fast_location/src/shared/storage/storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../../helpers/fakes.dart';

void main() {
  late Directory tempDir;
  late AddressLocalRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fast_location_test');
    Hive.init(tempDir.path);
    HiveConfig.registerAdapters();
    await HiveConfig.openBoxes();
    repository = AddressLocalRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('começa sem histórico', () async {
    expect(await repository.getHistory(), isEmpty);
    expect(await repository.getLastAddress(), isNull);
  });

  test('salva com o adapter gerado e lê pelo CEP', () async {
    final consulted = pracaDaSe.copyWith(consultedAt: DateTime(2026, 11, 7));
    await repository.save(consulted);

    // Fecha e reabre a caixa para garantir que o dado veio do disco.
    await Hive.box<AddressModel>(StorageKeys.addressHistoryBox).close();
    await HiveConfig.openBoxes();
    repository = AddressLocalRepository();

    final stored = await repository.getByCep('01001000');
    expect(stored, isNotNull);
    expect(stored!.logradouro, 'Praça da Sé');
    expect(stored.ibge, '3550308');
    expect(stored.consultedAt, DateTime(2026, 11, 7));
  });

  test('ordena do mais recente para o mais antigo, sem duplicar', () async {
    await repository.save(pracaDaSe.copyWith(consultedAt: DateTime(2026, 1)));
    await repository.save(
      felipeSchmidt.copyWith(consultedAt: DateTime(2026, 2)),
    );
    // Mesmo CEP consultado de novo: substitui o registro anterior.
    await repository.save(pracaDaSe.copyWith(consultedAt: DateTime(2026, 3)));

    final history = await repository.getHistory();
    expect(history.map((a) => a.cepDigits), ['01001000', '88010001']);
    expect((await repository.getLastAddress())!.cepDigits, '01001000');
  });

  test('limpa o histórico', () async {
    await repository.save(pracaDaSe.copyWith(consultedAt: DateTime(2026)));
    await repository.clear();

    expect(await repository.getHistory(), isEmpty);
  });
}
