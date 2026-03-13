import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/spell_model.dart';
import 'package:hive/hive.dart';

class SpellRepository {
  final api = DndApiService();

  List<SpellModel> getSpells() {
    final box = Hive.box<SpellModel>('spells_cache');
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

      final spellsJson = await Future.wait(futures);

      spells.addAll(
        spellsJson.map((json) => SpellModel.fromJson(json)),
      );

      print("Downloaded ${spells.length}/${spellIndexes.length}");
    }

    await box.clear();
    await box.addAll(spells);

    print("Cache de magias atualizado!");
  }

  Future<SpellModel?> getSpellByIndex(String index) async {
    final box = Hive.box<SpellModel>('spells_cache');

    final cached = box.values.where((s) => s.index == index).firstOrNull;

    if (cached != null) {
      return cached;
    }

    try {
      final data = await api.fetchSpellsDetail(index);
      final spell = SpellModel.fromJson(data);

      await box.add(spell);

      return spell;
    } catch (e) {
      print("Erro ao buscar magias: $e");
      return null;
    }
  }
}
