// =============================================================================
// Passo 05 do desafio - módulo Home, diretório repositories:
// "criar classe para se comunicar com a API externa".
// =============================================================================

import 'package:dio/dio.dart';

import '../../../http/dio_client.dart';
import '../model/address_exceptions.dart';
import '../model/address_model.dart';

/// Comunicação com a API externa ViaCEP.
///
/// Endpoints usados:
/// * `GET /ws/{cep}/json/` – endereço de um CEP;
/// * `GET /ws/{UF}/{cidade}/{logradouro}/json/` – CEPs de um endereço
///   completo ou parcial (cidade e logradouro com no mínimo 3 letras).
///
/// O repositório só busca e converte os dados; as regras de negócio
/// (validação, histórico, cache) ficam no AddressService.
class AddressRepository {
  /// O Dio pode ser informado (nos testes) ou usar a instância configurada
  /// em DioClient (no app).
  AddressRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  /// Busca o endereço de um [cep] (somente números).
  Future<AddressModel> getAddressByCep(String cep) async {
    try {
      // Ex.: https://viacep.com.br/ws/01001000/json/
      final response = await _dio.get<dynamic>('/$cep/json/');
      final data = response.data;

      // Para CEPs inexistentes a API responde 200 com {"erro": true}.
      if (data is! Map<String, dynamic> || _isNotFound(data)) {
        throw const AddressNotFoundException();
      }

      return AddressModel.fromJson(data);
    } on DioError catch (error) {
      // Erros do Dio (rede, tempo esgotado, HTTP 400...) viram erros do app.
      throw _mapError(error, invalidRequest: const InvalidCepException());
    }
  }

  /// Busca os CEPs que correspondem ao endereço informado.
  ///
  /// Retorna uma lista vazia quando nada é encontrado.
  Future<List<AddressModel>> searchAddresses({
    required String uf,
    required String city,
    required String street,
  }) async {
    // Uri.encodeComponent troca espaços e acentos por códigos aceitos na
    // URL. Ex.: "São Paulo" -> "S%C3%A3o%20Paulo".
    final path = '/${Uri.encodeComponent(uf)}'
        '/${Uri.encodeComponent(city)}'
        '/${Uri.encodeComponent(street)}/json/';

    try {
      final response = await _dio.get<dynamic>(path);
      final data = response.data;

      // Nessa consulta a API devolve uma lista (até 50 endereços).
      if (data is! List) return const [];

      return data
          .whereType<Map<String, dynamic>>()
          .where((json) => !_isNotFound(json))
          .map(AddressModel.fromJson)
          .toList();
    } on DioError catch (error) {
      throw _mapError(
        error,
        invalidRequest: const InvalidAddressSearchException(
          'Confira a UF, a cidade e o logradouro informados.',
        ),
      );
    }
  }

  /// A ViaCEP indica "não encontrado" com `"erro": true`; versões mais novas
  /// da API devolvem o valor como texto (`"erro": "true"`).
  bool _isNotFound(Map<String, dynamic> json) {
    final error = json['erro'];
    return error == true || error.toString() == 'true';
  }

  /// Converte um erro do Dio no erro correspondente do app.
  AddressException _mapError(
    DioError error, {
    required AddressException invalidRequest,
  }) {
    // A API responde 400 quando o formato do CEP/endereço é inválido.
    if (error.type == DioErrorType.response &&
        error.response?.statusCode == 400) {
      return invalidRequest;
    }

    // Qualquer outro problema (sem internet, tempo esgotado, servidor fora
    // do ar) é tratado como falha de conexão.
    return const AddressConnectionException();
  }
}
