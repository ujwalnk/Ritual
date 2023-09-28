// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ritual.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RitualAdapter extends TypeAdapter<Ritual> {
  @override
  final int typeId = 0;

  @override
  Ritual read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ritual()
      ..complete = fields[0] as double
      ..url = fields[1] as String
      ..background = fields[2] as String?
      ..time = fields[3] as String?
      ..type = fields[4] as String?
      ..expiry = fields[5] as DateTime?
      ..position = fields[6] as int?
      ..priority = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, Ritual obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.complete)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.background)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.expiry)
      ..writeByte(6)
      ..write(obj.position)
      ..writeByte(7)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RitualAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
