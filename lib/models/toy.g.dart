// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToyAdapter extends TypeAdapter<Toy> {
  @override
  final int typeId = 1;

  @override
  Toy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Toy(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double,
      description: fields[4] as String,
      stockQuantity: fields[5] as int,
      imageUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Toy obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.stockQuantity)
      ..writeByte(6)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
