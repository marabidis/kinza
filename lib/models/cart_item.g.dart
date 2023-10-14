// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    print(
        'fields[5]: ${fields[5]}, fields[6]: ${fields[6]}'); // добавьте эту строку
    return CartItem(
      id: fields[0] as String,
      title: fields[1] as String,
      price: fields[2] as int,
      quantity: fields[3] as int,
      thumbnailUrl: fields[4] as String?,
      weight: fields[5] != null ? double.parse(fields[5].toString()) : null,
      minimumWeight:
          fields[6] != null ? double.parse(fields[6].toString()) : null,
      isWeightBased: fields[7] as bool? ?? false,
      unit: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.minimumWeight)
      ..writeByte(7)
      ..write(obj.isWeightBased)
      ..writeByte(8)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
