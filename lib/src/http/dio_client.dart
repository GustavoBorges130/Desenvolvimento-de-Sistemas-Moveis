// =============================================================================
// Passo 03 do desafio - diretório http (lib/src/http):
// "criar classe com configuração da dependência dio para a comunicação http
// com sistemas externos".
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configuração do Dio para a comunicação HTTP com sistemas externos.
///
/// O app consome a API pública ViaCEP (https://viacep.com.br), que não exige
/// autenticação e responde em JSON.
class DioClient {
  // Construtor privado: a classe só expõe membros estáticos e não deve ser
  // instanciada.
  DioClient._();

  /// Endereço base da API. Os repositórios completam com o caminho de cada
  /// consulta, por exemplo `/01001000/json/`.
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';

  /// Tempo máximo, em milissegundos, para conectar e para receber a resposta.
  ///
  /// No dio 4.x os tempos são informados em milissegundos (inteiro).
  static const int timeoutInMilliseconds = 15000;

  /// Guarda a instância já criada (padrão Singleton).
  static Dio? _instance;

  /// Instância única do Dio compartilhada pelos repositórios.
  ///
  /// O operador `??=` cria o Dio apenas na primeira vez que for usado.
  static Dio get instance => _instance ??= create();

  /// Cria um Dio configurado. Também é usado nos testes, que trocam o
  /// adaptador HTTP para não acessar a internet.
  static Dio create({String baseUrl = viaCepBaseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeoutInMilliseconds,
        receiveTimeout: timeoutInMilliseconds,
        sendTimeout: timeoutInMilliseconds,
        // Converte automaticamente a resposta JSON em Map/List do Dart.
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    // Em modo debug, mostra no console as requisições e respostas, o que
    // ajuda a acompanhar as consultas durante o desenvolvimento. Na versão
    // de produção (release) o log fica desligado.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestHeader: false, responseHeader: false),
      );
    }

    return dio;
  }
}
