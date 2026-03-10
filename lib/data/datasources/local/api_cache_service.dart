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
      await raceRepository.refreshRaces();
    } catch (e) {
      print("API indisponivel, usando cached data local");
    }
  }
}
