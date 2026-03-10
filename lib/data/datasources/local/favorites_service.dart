import 'package:hive/hive.dart';

import '../../../models/spell_model.dart';

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
