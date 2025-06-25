// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressTypeAdapter extends TypeAdapter<AddressType> {
  @override
  final int typeId = 30;

  @override
  AddressType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AddressType.home;
      case 1:
        return AddressType.work;
      case 2:
        return AddressType.other;
      default:
        return AddressType.home;
    }
  }

  @override
  void write(BinaryWriter writer, AddressType obj) {
    switch (obj) {
      case AddressType.home:
        writer.writeByte(0);
        break;
      case AddressType.work:
        writer.writeByte(1);
        break;
      case AddressType.other:
        writer.writeByte(2);
        break;
    }
  }
}

class AddressAdapter extends TypeAdapter<Address> {
  @override
  final int typeId = 31;

  @override
  Address read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Address(
      id: fields[0] as int,
      type: fields[1] as AddressType,
      street: fields[2] as String,
      house: fields[3] as String,
      flat: fields[4] as String?,
      comment: fields[5] as String?,
      lat: fields[6] as double?,
      lng: fields[7] as double?,
      isDefault: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Address obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.street)
      ..writeByte(3)
      ..write(obj.house)
      ..writeByte(4)
      ..write(obj.flat)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.lat)
      ..writeByte(7)
      ..write(obj.lng)
      ..writeByte(8)
      ..write(obj.isDefault);
  }
}
