// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spell_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpellModelAdapter extends TypeAdapter<SpellModel> {
  @override
  final int typeId = 0;

  @override
  SpellModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpellModel(
      index: fields[0] as String,
      name: fields[1] as String,
      school: fields[2] as String,
      level: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SpellModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.index)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.school)
      ..writeByte(3)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpellModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
