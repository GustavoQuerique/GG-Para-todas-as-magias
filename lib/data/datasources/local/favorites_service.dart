import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:hive/hive.dart';

class FavoritesService {
  final Box<SpellModel> box = Hive.box<SpellModel>('favorites');

  bool isFavorite(String index) {
    return box.containsKey(index);
  }

  void addFavorite(SpellModel spell) {
    box.put(spell.index, spell);
  }

  void removeFavorite(String index) {
    box.delete(index);
  }

  List<SpellModel> getFavorites() {
    return box.values.toList();
  }
}
