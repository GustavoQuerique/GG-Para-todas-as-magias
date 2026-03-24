// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiaryModelAdapter extends TypeAdapter<DiaryModel> {
  @override
  final int typeId = 6;

  @override
  DiaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryModel(
      title: fields[0] as String,
      entries: (fields[1] as List).cast<DiaryEntry>(),
      lastUpdate: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.entries)
      ..writeByte(2)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DiaryEntryAdapter extends TypeAdapter<DiaryEntry> {
  @override
  final int typeId = 7;

  @override
  DiaryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiaryEntry(
      text: fields[0] as String,
      date: fields[1] as DateTime,
      session: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DiaryEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.session);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
