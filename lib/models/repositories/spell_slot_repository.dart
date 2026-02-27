import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';

class SpellSlotRepository {
  static final SpellSlotRepository _instance = SpellSlotRepository._internal();

  factory SpellSlotRepository() {
    return _instance;
  }

  SpellSlotRepository._internal();

  final Map<String, List<dynamic>> _levelsCache = {};

  Future<Map<int, int>> getSpellSlots({
    required String classIndex,
    required int level,
  }) async {
    if (!_levelsCache.containsKey(classIndex)) {
      final api = DndApiService();
      _levelsCache[classIndex] = await api.fetchLevelsForClass(classIndex);
    }

    final levels = _levelsCache[classIndex]!;

    final levelData = levels.firstWhere((e) => e["level"] == level);

    if (levelData["spellcasting"] == null) return {};

    final spellcasting = levelData["spellcasting"];

    Map<int, int> slots = {};

    for (int i = 1; i <= 9; i++) {
      final key = "spell_slots_level_$i";
      if (spellcasting[key] != null && spellcasting[key] > 0) {
        slots[i] = spellcasting[key];
      }
    }

    return slots;
  }
}
