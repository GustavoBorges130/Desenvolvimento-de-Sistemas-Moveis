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
class AddressRepository {
  AddressRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  /// Busca o endereço de um [cep] (somente números).
  Future<AddressModel> getAddressByCep(String cep) async {
    try {
      final response = await _dio.get<dynamic>('/$cep/json/');
      final data = response.data;

      // Para CEPs inexistentes a API responde 200 com {"erro": true}.
      if (data is! Map<String, dynamic> || _isNotFound(data)) {
        throw const AddressNotFoundException();
      }

      return AddressModel.fromJson(data);
    } on DioError catch (error) {
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
    final path = '/${Uri.encodeComponent(uf)}'
        '/${Uri.encodeComponent(city)}'
        '/${Uri.encodeComponent(street)}/json/';

    try {
      final response = await _dio.get<dynamic>(path);
      final data = response.data;

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

  bool _isNotFound(Map<String, dynamic> json) {
    final error = json['erro'];
    return error == true || error.toString() == 'true';
  }

  AddressException _mapError(
    DioError error, {
    required AddressException invalidRequest,
  }) {
    // A API responde 400 quando o formato do CEP/endereço é inválido.
    if (error.type == DioErrorType.response &&
        error.response?.statusCode == 400) {
      return invalidRequest;
    }

    return const AddressConnectionException();
  }
}
