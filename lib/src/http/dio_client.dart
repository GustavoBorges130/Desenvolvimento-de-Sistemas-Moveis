import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configuração do Dio para a comunicação HTTP com sistemas externos.
///
/// O app consome a API pública ViaCEP (https://viacep.com.br), que não exige
/// autenticação e responde em JSON.
class DioClient {
  DioClient._();

  static const String viaCepBaseUrl = 'https://viacep.com.br/ws';

  /// Tempo máximo, em milissegundos, para conectar e para receber a resposta.
  static const int timeoutInMilliseconds = 15000;

  static Dio? _instance;

  /// Instância única do Dio compartilhada pelos repositórios.
  static Dio get instance => _instance ??= create();

  static Dio create({String baseUrl = viaCepBaseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeoutInMilliseconds,
        receiveTimeout: timeoutInMilliseconds,
        sendTimeout: timeoutInMilliseconds,
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestHeader: false, responseHeader: false),
      );
    }

    return dio;
  }
}
