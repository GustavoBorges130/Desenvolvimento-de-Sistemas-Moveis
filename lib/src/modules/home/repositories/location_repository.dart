import 'package:geocoding/geocoding.dart';

/// Conversão de endereço em coordenadas (geocodificação) usando o serviço
/// nativo do aparelho, por meio da biblioteca geocoding.
class LocationRepository {
  /// Retorna as coordenadas encontradas para o [address] informado.
  ///
  /// Pode retornar uma lista vazia ou lançar exceção quando o serviço do
  /// aparelho não reconhece o endereço.
  Future<List<Location>> getLocations(String address) {
    return locationFromAddress(address);
  }
}
