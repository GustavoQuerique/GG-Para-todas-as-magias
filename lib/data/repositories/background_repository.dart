import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_background.dart';

class BackgroundRepository {
  static final BackgroundRepository _instance =
      BackgroundRepository._internal();

  factory BackgroundRepository() {
    return _instance;
  }

  BackgroundRepository._internal();

  final List<DndBackground> _backgrounds = [
    DndBackground(index: "acolyte", name: "Acolyte"),
    DndBackground(index: "charlatan", name: "Charlatan"),
    DndBackground(index: "criminal", name: "Criminal"),
    DndBackground(index: "entertainer", name: "Entertainer"),
    DndBackground(index: "folk-hero", name: "Folk Hero"),
    DndBackground(index: "guild-artisan", name: "Guild Artisan"),
    DndBackground(index: "hermit", name: "Hermit"),
    DndBackground(index: "noble", name: "Noble"),
    DndBackground(index: "outlander", name: "Outlander"),
    DndBackground(index: "sage", name: "Sage"),
    DndBackground(index: "sailor", name: "Sailor"),
    DndBackground(index: "soldier", name: "Soldier"),
    DndBackground(index: "urchin", name: "Urchin"),
  ];

  Future<List<DndBackground>> getBackground() async {
    return _backgrounds;
  }
}
