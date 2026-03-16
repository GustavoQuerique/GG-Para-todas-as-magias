import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/spell_model.dart';
import 'package:hive/hive.dart';

class SpellRepository {
  final api = DndApiService();

  Future<Box<SpellModel>> _getBox() async {
    if (Hive.isBoxOpen('spells_cache')) {
      return Hive.box<SpellModel>('spells_cache');
    }

    return await Hive.openBox<SpellModel>('spells_cache');
  }

  Future<List<SpellModel>> getSpells() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> refreshSpells() async {
    final box = Hive.box<SpellModel>('spells_cache');

    print("Baixando lista de magias...");

    final spellIndexes = await api.fetchSpells();

    const batchSize = 20;

    List<SpellModel> spells = [];

    for (int i = 0; i < spellIndexes.length; i += batchSize) {
      final batch = spellIndexes.skip(i).take(batchSize);

      final futures = batch.map((spell) {
        return api.fetchSpellsDetail(spell['index']);
      });

      final spellsJson = await Future.wait(
        futures.map((f) => f.catchError((_) => null)),
      );

      spells.addAll(
        spellsJson
            .where((json) => json != null)
            .map((json) => SpellModel.fromJson(json)),
      );

      print("Downloaded ${spells.length}/${spellIndexes.length}");
    }

    await box.clear();
    for (final spell in spells) {
      await box.put(spell.index, spell);
    }

    print("Cache de magias atualizado!");
  }

  Future<SpellModel?> getSpellByIndex(String index) async {
    final box = await _getBox();

    final cached = box.get(index);
    if (cached != null) return cached;

    final data = await api.fetchSpellsDetail(index);
    final spell = SpellModel.fromJson(data);

    await box.put(index, spell);

    return spell;
  }
}
