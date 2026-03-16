import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/spell_model.dart';
import 'package:hive/hive.dart';

class SpellRepository {
  final api = DndApiService();
  static const String _boxName = 'spells_cached';

  // Centraliza a abertura da box para evitar erro de "Box not open"
  Future<Box<SpellModel>> _getBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box<SpellModel>(_boxName)
        : await Hive.openBox<SpellModel>(_boxName);
  }

  Future<List<SpellModel>> getSpells() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> refreshSpells() async {
    final box = await _getBox();

    print("Baixando lista de magias...");
    final spellIndexes = await api.fetchSpells();

    const batchSize = 20;
    List<SpellModel> spells = [];

    for (int i = 0; i < spellIndexes.length; i += batchSize) {
      final batch = spellIndexes.skip(i).take(batchSize);

      final futures = batch.map(
        (spell) => api.fetchSpellsDetail(spell['index']),
      );

      // Aguarda o lote de requisições
      final results = await Future.wait(
        futures.map(
          (f) => f.catchError((e) {
            print("Erro ao baixar magia: $e");
            return null;
          }),
        ),
      );

      for (var json in results) {
        if (json != null) {
          try {
            spells.add(SpellModel.fromJson(json));
          } catch (e) {
            print("Erro ao converter JSON para SpellModel: $e");
          }
        }
      }

      print("Downloaded ${spells.length}/${spellIndexes.length}");
    }

    // Otimização: Limpar e inserir tudo de uma vez (putAll)
    await box.clear();
    final Map<String, SpellModel> spellMap = {
      for (var spell in spells) spell.index: spell,
    };
    await box.putAll(spellMap);

    print("Cache de magias atualizado com ${spells.length} magias!");
  }

  Future<SpellModel?> getSpellByIndex(String index) async {
    final box = await _getBox();
    final cached = box.get(index);

    if (cached != null) return cached;

    try {
      final data = await api.fetchSpellsDetail(index);
      final spell = SpellModel.fromJson(data);
      await box.put(index, spell);
      return spell;
    } catch (e) {
      print("Erro ao buscar detalhe da magia $index: $e");
      return null;
    }
  }
}
