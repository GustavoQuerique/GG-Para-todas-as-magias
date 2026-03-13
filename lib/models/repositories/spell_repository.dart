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
}

// Future<List<SpellModel>> getSpells() async {
//   final box = await Hive.openBox<SpellModel>('spells_cache');
//
//   if (box.isEmpty) {
//     await _downloadAllSpells(box);
//   }
//
//   return box.values.toList();
// }
//
// Future<void> refreshSpells() async {
//   final box = await Hive.openBox<SpellModel>('spells_cache');
//
//   if (box.isNotEmpty) {
//     print("Spells already cached");
//     return;
//   }
//
//   await _downloadAllSpells(box);
// }
//
// Future<void> ensureCache() async {
//   final box = await Hive.openBox<SpellModel>('spells_cache');
//
//   if (box.isEmpty) {
//     await _downloadAllSpells(box);
//   }
// }
//
// Future<void> _downloadAllSpells(Box<SpellModel> box) async {
//   final spellIndexes = await api.fetchSpells();
//
//   const batchSize = 20;
//
//   for (int i = 0; i < spellIndexes.length; i += batchSize) {
//     final batch = spellIndexes.skip(i).take(batchSize);
//
//     final futures = batch.map((spell) {
//       return api.fetchSpellsDetail(spell['index']);
//     });
//
//     final spellsJson = await Future.wait(futures);
//
//     final spells = spellsJson
//         .map((json) => SpellModel.fromJson(json))
//         .toList();
//
//     await box.addAll(spells);
//
//     print("Downloaded ${i + spells.length}/${spellIndexes.length} spells");
//
//     // DELAY AQUI
//     await Future.delayed(const Duration(milliseconds: 200));
//   }
// }
