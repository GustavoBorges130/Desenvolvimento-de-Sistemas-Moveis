// =============================================================================
// Passo 05 do desafio - módulo Home, diretório repositories:
// comunicação com o serviço de geocodificação do aparelho (dependência
// geocoding), usado na ação de traçar a rota.
// =============================================================================

import 'package:geocoding/geocoding.dart';

/// Conversão de endereço em coordenadas (geocodificação) usando o serviço
/// nativo do aparelho, por meio da biblioteca geocoding.
///
/// A ViaCEP não devolve latitude e longitude; elas são necessárias para o
/// app de mapas traçar a rota até o endereço.
class LocationRepository {
  /// Retorna as coordenadas encontradas para o [address] informado.
  ///
  /// Pode retornar uma lista vazia ou lançar exceção quando o serviço do
  /// aparelho não reconhece o endereço.
  Future<List<Location>> getLocations(String address) {
    return locationFromAddress(address);
  }
}
