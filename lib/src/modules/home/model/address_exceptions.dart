/// Erros conhecidos das consultas de endereço.
///
/// Cada erro carrega uma mensagem pronta para ser exibida ao entregador.
sealed class AddressException implements Exception {
  const AddressException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// CEP digitado fora do formato esperado (8 dígitos).
class InvalidCepException extends AddressException {
  const InvalidCepException([
    super.message = 'Informe um CEP válido, com 8 dígitos.',
  ]);
}

/// Dados da busca por endereço incompletos ou inválidos.
class InvalidAddressSearchException extends AddressException {
  const InvalidAddressSearchException(super.message);
}

/// A consulta foi feita, mas a API não encontrou o CEP/endereço.
class AddressNotFoundException extends AddressException {
  const AddressNotFoundException([
    super.message = 'Não encontramos nenhum endereço para o CEP informado.',
  ]);
}

/// Falha de comunicação com a API (sem internet, tempo esgotado etc.).
class AddressConnectionException extends AddressException {
  const AddressConnectionException([
    super.message = 'Não foi possível consultar o endereço. Verifique a '
        'conexão com a internet e tente novamente.',
  ]);
}

/// Não foi possível converter o endereço em coordenadas para a rota.
class AddressLocationException extends AddressException {
  const AddressLocationException([
    super.message = 'Não foi possível localizar este endereço no mapa.',
  ]);
}
