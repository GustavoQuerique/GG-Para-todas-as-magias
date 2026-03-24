import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_container.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_item_instance.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_item.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_inventory_equipment/equipment_section.dart';
import 'package:hive/hive.dart';

part 'character_sheet.g.dart';

@HiveType(typeId: 3)
enum WeightUnit {
  @HiveField(0)
  lb,

  @HiveField(1)
  kg,
}

@HiveType(typeId: 1)
class CharacterSheet extends HiveObject {
  //IDENTIDADE

  @HiveField(0)
  String name;

  @HiveField(1)
  int level;

  @HiveField(2)
  String? raceIndex; // ex: "elf"

  @HiveField(3)
  String? classIndex; // ex: "wizard"

  @HiveField(4)
  String? backgroundIndex;

  @HiveField(5)
  String? alignment;

  // ATRIBUTOS

  @HiveField(6)
  int strength;

  @HiveField(7)
  int dexterity;

  @HiveField(8)
  int constitution;

  @HiveField(9)
  int intelligence;

  @HiveField(10)
  int wisdom;

  @HiveField(11)
  int charisma;

  // COMBATE

  @HiveField(12)
  int armorClass;

  @HiveField(13)
  int maxHp;

  @HiveField(14)
  int currentHp;

  // LISTAS

  @HiveField(15)
  List<String> proficientSkills;

  @HiveField(16)
  Map<int, List<String>> spellsByLevel;

  @HiveField(17)
  List<InventoryItem> inventory;

  @HiveField(18)
  int copper;

  @HiveField(19)
  int silver;

  @HiveField(20)
  int electrum;

  @HiveField(21)
  int gold;

  @HiveField(22)
  int platinum;

  @HiveField(23)
  WeightUnit weightUnit;

  //MOVIMENTO

  @HiveField(24)
  int initiative;

  @HiveField(25)
  int speed;

  //ROLEPLAY

  @HiveField(26)
  String? personalityTraits;

  @HiveField(27)
  String? ideals;

  @HiveField(28)
  String? bonds;

  @HiveField(29)
  String? flaws;

  @HiveField(30)
  String? backStory;

  //FETCHSPELLSLOTS

  @HiveField(31)
  Map<int, int> spellSlots;

  @HiveField(32)
  List<Map<String, dynamic>> inventoryGridItems = [];

  @HiveField(33)
  int inventoryTypeIndex;

  @HiveField(34)
  Map<String, Map<String, dynamic>?> equippedItems = {};

  @HiveField(35)
  String? imagePath;

  CharacterSheet({
    required this.name,
    required this.level,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    required this.armorClass,
    required this.maxHp,
    required this.currentHp,
    this.raceIndex,
    this.classIndex,
    this.backgroundIndex,
    this.alignment,
    this.weightUnit = WeightUnit.lb,
    List<String>? proficientSkills,
    Map<int, List<String>>? spellsByLevel,
    List<InventoryItem>? inventory,
    this.copper = 0,
    this.silver = 0,
    this.electrum = 0,
    this.gold = 0,
    this.platinum = 0,
    this.initiative = 0,
    this.speed = 9,
    this.personalityTraits,
    this.ideals,
    this.flaws,
    this.bonds,
    this.backStory,
    Map<int, int>? spellSlots,
    List<Map<String, dynamic>>? inventoryGridItems,
    int? inventoryTypeIndex,
    Map<String, Map<String, dynamic>>? equippedItems,
    this.imagePath,
  }) : proficientSkills = proficientSkills ?? [],
       spellsByLevel =
           spellsByLevel ??
           {
             for (int i = 0; i <= 9; i++) i: [],
           },
       spellSlots = spellSlots ?? {},
       inventory = inventory ?? [],
       inventoryGridItems = inventoryGridItems ?? [],
       inventoryTypeIndex =
           inventoryTypeIndex ?? InventoryType.mediumBackpack.index,
       equippedItems = equippedItems ?? {};

  //Getters

  double get carryingCapacity => strength * 15;

  ///deprecated
  double get currentWeight =>
      inventory.fold(0, (sum, item) => sum + item.totalWeight);

  double get weightRatio =>
      carryingCapacity == 0 ? 0 : currentWeight / carryingCapacity;

  late final ValueNotifier<WeightUnit> weightUnitNotifier = ValueNotifier(
    weightUnit,
  );

  void toggleWeightUnit() {
    weightUnit = weightUnit == WeightUnit.lb ? WeightUnit.kg : WeightUnit.lb;

    weightUnitNotifier.value = weightUnit;
    save();
  }

  double convertWeight(double valueInLb) {
    if (weightUnit == WeightUnit.kg) {
      return valueInLb * 0.453592;
    }
    return valueInLb;
  }

  String get weightLabel => weightUnit == WeightUnit.kg ? "kg" : "lb";

  int get proficiencyBonus {
    if (level >= 17) return 6;
    if (level >= 13) return 5;
    if (level >= 9) return 4;
    if (level >= 5) return 3;
    return 2;
  }

  int get strengthMod => _modifier(strength);
  int get dexterityMod => _modifier(dexterity);
  int get constitutionMod => _modifier(constitution);
  int get intelligenceMod => _modifier(intelligence);
  int get wisdomMod => _modifier(wisdom);
  int get charismaMod => _modifier(charisma);

  int _modifier(int value) {
    return ((value - 10) / 2).floor();
  }

  //helper dos equipamentos
  Map<EquipmentSlot, InventoryItemInstance?> get getEquippedItemsParsed {
    final result = <EquipmentSlot, InventoryItemInstance?>{};

    for (var slot in EquipmentSlot.values) {
      final json = equippedItems[slot.name];

      if (json != null) {
        result[slot] = InventoryItemInstance.fromJson(json);
      } else {
        result[slot] = null;
      }
    }

    return result;
  }

  void updateEquippedItemsFromParsed(
    Map<EquipmentSlot, InventoryItemInstance?> parsed,
  ) {
    equippedItems.clear();

    for (var entry in parsed.entries) {
      equippedItems[entry.key.name] = entry.value?.toJson();
    }
  }

  //
  // FACTORY PADRÃO (Criar ficha nova)
  //

  factory CharacterSheet.empty() {
    return CharacterSheet(
      name: "Novo Personagem",
      level: 1,
      strength: 10,
      dexterity: 10,
      constitution: 10,
      intelligence: 10,
      wisdom: 10,
      charisma: 10,
      armorClass: 10,
      maxHp: 10,
      currentHp: 10,
    );
  }

  //
  // FACTORY PARA IMPORTAR JSON (se precisar no futuro)
  //

  factory CharacterSheet.fromJson(Map<String, dynamic> json) {
    //Spells
    Map<int, List<String>> parsedSpells = {for (int i = 0; i <= 9; i++) i: []};

    if (json['spellsByLevel'] != null) {
      final rawMap = Map<String, dynamic>.from(json['spellsByLevel']);

      rawMap.forEach((key, value) {
        final level = int.tryParse(key);
        if (level != null) {
          parsedSpells[level] = List<String>.from(value);
        }
      });
    }

    Map<int, int> parsedSpellSlots = {};

    if (json['spellSlots'] != null) {
      final raw = Map<String, dynamic>.from(json['spellSlots']);

      raw.forEach((key, value) {
        final level = int.tryParse(key);
        if (level != null) {
          parsedSpellSlots[level] = value;
        }
      });
    }

    //Inventory
    List<InventoryItem> parsedInventory = [];

    if (json['inventory'] != null) {
      parsedInventory = (json['inventory'] as List)
          .map(
            (item) => InventoryItem(
              name: item['name'],
              weight: (item['weight'] as num).toDouble(),
              quantity: item['quantity'],
            ),
          )
          .toList();
    }

    return CharacterSheet(
      name: json['name'],
      level: json['level'],
      raceIndex: json['raceIndex'],
      classIndex: json['classIndex'],
      backgroundIndex: json['backgroundIndex'],
      alignment: json['alignment'],
      strength: json['strength'],
      dexterity: json['dexterity'],
      constitution: json['constitution'],
      intelligence: json['intelligence'],
      wisdom: json['wisdom'],
      charisma: json['charisma'],
      armorClass: json['armorClass'],
      maxHp: json['maxHp'],
      currentHp: json['currentHp'],
      proficientSkills: List<String>.from(json['proficientSkills'] ?? []),
      spellsByLevel: parsedSpells,
      inventory: parsedInventory,
      weightUnit: json['weightUnit'] == 'kg' ? WeightUnit.kg : WeightUnit.lb,

      //  Moedas
      copper: json['copper'] ?? 0,
      silver: json['silver'] ?? 0,
      electrum: json['electrum'] ?? 0,
      gold: json['gold'] ?? 0,
      platinum: json['platinum'] ?? 0,

      // Movimento
      speed: json['speed'],
      initiative: json['initiative'],

      // Roleplay
      personalityTraits: json['personalityTraits'],
      ideals: json['ideals'],
      bonds: json['bonds'],
      flaws: json['flaws'],
      backStory: json['backStory'],

      //SpellSlots
      spellSlots: parsedSpellSlots,

      inventoryGridItems: List<Map<String, dynamic>>.from(
        json['inventoryGridItem'] ?? [],
      ),

      equippedItems: Map<String, Map<String, dynamic>>.from(
        json['equippedItems'],
      ),

      inventoryTypeIndex:
          json['inventoryTypeIndex'] ?? InventoryType.mediumBackpack.index,

      imagePath: json['imagePath'],
    );
  }

  //
  // CONVERTER PARA MAP (Export / Backup)
  //

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'raceIndex': raceIndex,
      'classIndex': classIndex,
      'backgroundIndex': backgroundIndex,
      'alignment': alignment,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'armorClass': armorClass,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'proficientSkills': proficientSkills,

      //Spells
      'spellsByLevel': spellsByLevel.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'spellSlots': spellSlots.map(
        (key, value) => MapEntry(key.toString(), value),
      ),

      //Inventory
      'weightUnit': weightUnit.name,
      'inventory': inventory
          .map(
            (item) => {
              'name': item.name,
              'weight': item.weight,
              'quantity': item.quantity,
            },
          )
          .toList(),

      //Moedas
      'copper': copper,
      'silver': silver,
      'electrum': electrum,
      'gold': gold,
      'platinum': platinum,

      //Movimento
      'speed': speed,
      'initiative': initiative,

      //Roleplay
      'personalityTraits': personalityTraits,
      'ideals': ideals,
      'bonds': bonds,
      'flaws': flaws,
      'backStory': backStory,

      'inventoryGridItems': inventoryGridItems,
      'inventoryTypeIndex': inventoryTypeIndex,

      'equippedItems': equippedItems,

      'imagePath': imagePath,
    };
  }
}
