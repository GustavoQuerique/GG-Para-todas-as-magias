// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_sheet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CharacterSheetAdapter extends TypeAdapter<CharacterSheet> {
  @override
  final int typeId = 1;

  @override
  CharacterSheet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterSheet(
      name: fields[0] as String,
      level: fields[1] as int,
      strength: fields[6] as int,
      dexterity: fields[7] as int,
      constitution: fields[8] as int,
      intelligence: fields[9] as int,
      wisdom: fields[10] as int,
      charisma: fields[11] as int,
      armorClass: fields[12] as int,
      maxHp: fields[13] as int,
      currentHp: fields[14] as int,
      raceIndex: fields[2] as String?,
      classIndex: fields[3] as String?,
      backgroundIndex: fields[4] as String?,
      alignment: fields[5] as String?,
      weightUnit: fields[23] as WeightUnit,
      proficientSkills: (fields[15] as List?)?.cast<String>(),
      spellsByLevel: (fields[16] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as int, (v as List).cast<String>())),
      inventory: (fields[17] as List?)?.cast<InventoryItem>(),
      copper: fields[18] as int,
      silver: fields[19] as int,
      electrum: fields[20] as int,
      gold: fields[21] as int,
      platinum: fields[22] as int,
      initiative: fields[24] as int,
      speed: fields[25] as int,
      personalityTraits: fields[26] as String?,
      ideals: fields[27] as String?,
      flaws: fields[29] as String?,
      bonds: fields[28] as String?,
      backStory: fields[30] as String?,
      spellSlots: (fields[31] as Map?)?.cast<int, int>(),
      inventoryGridItems: (fields[32] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
    );
  }

  @override
  void write(BinaryWriter writer, CharacterSheet obj) {
    writer
      ..writeByte(33)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.raceIndex)
      ..writeByte(3)
      ..write(obj.classIndex)
      ..writeByte(4)
      ..write(obj.backgroundIndex)
      ..writeByte(5)
      ..write(obj.alignment)
      ..writeByte(6)
      ..write(obj.strength)
      ..writeByte(7)
      ..write(obj.dexterity)
      ..writeByte(8)
      ..write(obj.constitution)
      ..writeByte(9)
      ..write(obj.intelligence)
      ..writeByte(10)
      ..write(obj.wisdom)
      ..writeByte(11)
      ..write(obj.charisma)
      ..writeByte(12)
      ..write(obj.armorClass)
      ..writeByte(13)
      ..write(obj.maxHp)
      ..writeByte(14)
      ..write(obj.currentHp)
      ..writeByte(15)
      ..write(obj.proficientSkills)
      ..writeByte(16)
      ..write(obj.spellsByLevel)
      ..writeByte(17)
      ..write(obj.inventory)
      ..writeByte(18)
      ..write(obj.copper)
      ..writeByte(19)
      ..write(obj.silver)
      ..writeByte(20)
      ..write(obj.electrum)
      ..writeByte(21)
      ..write(obj.gold)
      ..writeByte(22)
      ..write(obj.platinum)
      ..writeByte(23)
      ..write(obj.weightUnit)
      ..writeByte(24)
      ..write(obj.initiative)
      ..writeByte(25)
      ..write(obj.speed)
      ..writeByte(26)
      ..write(obj.personalityTraits)
      ..writeByte(27)
      ..write(obj.ideals)
      ..writeByte(28)
      ..write(obj.bonds)
      ..writeByte(29)
      ..write(obj.flaws)
      ..writeByte(30)
      ..write(obj.backStory)
      ..writeByte(31)
      ..write(obj.spellSlots)
      ..writeByte(32)
      ..write(obj.inventoryGridItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterSheetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightUnitAdapter extends TypeAdapter<WeightUnit> {
  @override
  final int typeId = 3;

  @override
  WeightUnit read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WeightUnit.lb;
      case 1:
        return WeightUnit.kg;
      default:
        return WeightUnit.lb;
    }
  }

  @override
  void write(BinaryWriter writer, WeightUnit obj) {
    switch (obj) {
      case WeightUnit.lb:
        writer.writeByte(0);
        break;
      case WeightUnit.kg:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightUnitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
