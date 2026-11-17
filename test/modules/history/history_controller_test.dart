import 'package:fast_location/src/modules/history/controller/history_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeAddressLocalRepository local;
  late HistoryController controller;

  setUp(() {
    local = FakeAddressLocalRepository();
    controller = HistoryController(local);
  });

  test('carrega o histórico do armazenamento local', () async {
    await local.save(pracaDaSe.copyWith(consultedAt: DateTime(2026, 1)));
    await local.save(felipeSchmidt.copyWith(consultedAt: DateTime(2026, 2)));

    await controller.loadHistory();

    expect(controller.isLoading, isFalse);
    expect(controller.total, 2);
    expect(controller.history.first.cepDigits, '88010001');
  });

  test('limpa o histórico', () async {
    await local.save(pracaDaSe.copyWith(consultedAt: DateTime(2026)));
    await controller.loadHistory();

    await controller.clearHistory();

    expect(controller.isEmpty, isTrue);
    expect(local.box, isEmpty);
  });
}
