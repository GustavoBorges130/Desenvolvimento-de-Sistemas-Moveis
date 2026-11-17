// Testes de widget das telas: abertura com redirecionamento, home (busca
// vazia, consulta por CEP, máscara, não encontrado, erro, busca por endereço)
// e histórico.

import 'package:fast_location/src/modules/history/controller/history_controller.dart';
import 'package:fast_location/src/modules/history/page/history_page.dart';
import 'package:fast_location/src/modules/home/controller/home_controller.dart';
import 'package:fast_location/src/modules/home/model/address_exceptions.dart';
import 'package:fast_location/src/modules/home/model/address_model.dart';
import 'package:fast_location/src/modules/home/page/home_page.dart';
import 'package:fast_location/src/modules/home/service/address_service.dart';
import 'package:fast_location/src/modules/initial/page/initial_page.dart';
import 'package:fast_location/src/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fakes.dart';

void main() {
  late FakeAddressRepository remote;
  late FakeAddressLocalRepository local;
  late HomeController homeController;

  setUp(() {
    remote = FakeAddressRepository()
      ..addresses['01001000'] = pracaDaSe
      ..addresses['88010001'] = felipeSchmidt;
    local = FakeAddressLocalRepository();
    final clock = FakeClock(DateTime(2026, 11, 17, 8));
    homeController = HomeController(
      AddressService(
        remoteRepository: remote,
        localRepository: local,
        locationRepository: FakeLocationRepository(),
        clock: () {
          clock.advance();
          return clock.now;
        },
      ),
    );
  });

  Widget buildApp({String initialRoute = AppRoutes.home}) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        AppRoutes.initial: (_) => const InitialPage(),
        AppRoutes.home: (_) => HomePage(controller: homeController),
        AppRoutes.history: (_) =>
            HistoryPage(controller: HistoryController(local)),
      },
    );
  }

  Future<void> searchCep(WidgetTester tester, String cep) async {
    await tester.tap(find.byKey(const Key('newSearchButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cepField')), cep);
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();
  }

  testWidgets('abertura anima e redireciona para a home', (tester) async {
    await tester.pumpWidget(buildApp(initialRoute: AppRoutes.initial));

    expect(find.text('FastLocation'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // Avança o relógio quadro a quadro pelo tempo da animação mais o tempo
    // em que a marca fica parada na tela.
    final total = InitialPage.animationDuration + InitialPage.holdDuration;
    const frame = Duration(milliseconds: 100);
    for (var elapsed = Duration.zero; elapsed <= total; elapsed += frame) {
      await tester.pump(frame);
    }
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(InitialPage), findsNothing);
  });

  testWidgets('home sem consultas mostra a busca vazia', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma consulta realizada'), findsOneWidget);
    expect(find.text('Traçar rota'), findsNothing);
  });

  testWidgets('consulta por CEP exibe o último endereço', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await searchCep(tester, '01001000');

    expect(find.text('CEP 01001-000'), findsOneWidget);
    expect(find.text('Praça da Sé, lado ímpar'), findsOneWidget);
    expect(find.text('Traçar rota'), findsOneWidget);
    expect(find.byKey(const Key('loadingComponent')), findsNothing);
  });

  testWidgets('máscara do CEP e validação do formulário', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('newSearchButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('cepField')), '0100');
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.text('Digite os 8 números do CEP'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('cepField')), '01001000');
    await tester.pump();
    expect(find.text('01001-000'), findsOneWidget);
  });

  testWidgets('CEP inexistente mostra endereço não encontrado', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await searchCep(tester, '99999999');

    expect(find.text('Endereço não encontrado'), findsOneWidget);
  });

  testWidgets('erro na consulta aparece pela reação do MobX', (tester) async {
    remote.error = const AddressConnectionException();
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await searchCep(tester, '01001000');

    expect(
      find.text(const AddressConnectionException().message),
      findsOneWidget,
    );
  });

  testWidgets('busca por endereço com vários resultados abre a escolha',
      (tester) async {
    remote.searchResult = [felipeSchmidt, felipeSchmidt2];
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('newSearchButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Por endereço'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ufField')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('SC').hitTestable(),
      48,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('SC').hitTestable().last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('cityField')),
      'Florianópolis',
    );
    await tester.enterText(
      find.byKey(const Key('streetField')),
      'Felipe Schmidt',
    );
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pumpAndSettle();

    expect(find.text('2 endereços encontrados'), findsOneWidget);

    await tester.tap(find.text('CEP 88010-002'));
    await tester.pumpAndSettle();

    expect(find.text('Rua Felipe Schmidt, de 391/392 ao fim'), findsOneWidget);
    expect(homeController.lastAddress!.cepDigits, '88010002');
  });

  testWidgets('histórico carrega ao abrir e devolve o endereço tocado',
      (tester) async {
    await local.save(pracaDaSe.copyWith(consultedAt: DateTime(2026, 1)));
    await local.save(felipeSchmidt.copyWith(consultedAt: DateTime(2026, 2)));
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('historyButton')));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.textContaining('2 endereços consultados'), findsOneWidget);

    await tester.tap(find.text('CEP 01001-000'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(homeController.lastAddress!.cepDigits, '01001000');
    expect(find.text('Praça da Sé, lado ímpar'), findsOneWidget);
  });

  testWidgets('histórico vazio mostra mensagem', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HistoryPage(controller: HistoryController(local))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma consulta no histórico'), findsOneWidget);
  });

  test('o modelo usado nas telas é o mesmo da API', () {
    expect(pracaDaSe, isA<AddressModel>());
  });
}
