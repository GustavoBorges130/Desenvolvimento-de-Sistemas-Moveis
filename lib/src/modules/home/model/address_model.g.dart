// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressModelAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 0;

  @override
  AddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressModel(
      cep: fields[0] == null ? '' : fields[0] as String,
      logradouro: fields[1] == null ? '' : fields[1] as String,
      complemento: fields[2] == null ? '' : fields[2] as String,
      unidade: fields[3] == null ? '' : fields[3] as String,
      bairro: fields[4] == null ? '' : fields[4] as String,
      localidade: fields[5] == null ? '' : fields[5] as String,
      uf: fields[6] == null ? '' : fields[6] as String,
      estado: fields[7] == null ? '' : fields[7] as String,
      regiao: fields[8] == null ? '' : fields[8] as String,
      ibge: fields[9] == null ? '' : fields[9] as String,
      gia: fields[10] == null ? '' : fields[10] as String,
      ddd: fields[11] == null ? '' : fields[11] as String,
      siafi: fields[12] == null ? '' : fields[12] as String,
      consultedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.cep)
      ..writeByte(1)
      ..write(obj.logradouro)
      ..writeByte(2)
      ..write(obj.complemento)
      ..writeByte(3)
      ..write(obj.unidade)
      ..writeByte(4)
      ..write(obj.bairro)
      ..writeByte(5)
      ..write(obj.localidade)
      ..writeByte(6)
      ..write(obj.uf)
      ..writeByte(7)
      ..write(obj.estado)
      ..writeByte(8)
      ..write(obj.regiao)
      ..writeByte(9)
      ..write(obj.ibge)
      ..writeByte(10)
      ..write(obj.gia)
      ..writeByte(11)
      ..write(obj.ddd)
      ..writeByte(12)
      ..write(obj.siafi)
      ..writeByte(13)
      ..write(obj.consultedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
