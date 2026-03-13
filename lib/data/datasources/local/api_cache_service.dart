import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/class_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/races_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/spell_repository.dart';

class ApiCacheService {
  final ClassRepository classRepository;
  final SpellRepository spellRepository;
  final RacesRepository raceRepository;

  ApiCacheService({
    required this.classRepository,
    required this.spellRepository,
    required this.raceRepository,
  });

  Future<void> initializeCache() async {
    try {
      await classRepository.refreshClasses();
    } catch (e) {
      print("Erro ao atualizar classes: $e");
    }

    try {
      await raceRepository.refreshRaces();
    } catch (e) {
      print("Erro ao atualizar raças: $e");
    }

    try {
      await spellRepository.refreshSpells();
    } catch (e) {
      print("Erro ao atualizar magias: $e");
    }
  }
}
