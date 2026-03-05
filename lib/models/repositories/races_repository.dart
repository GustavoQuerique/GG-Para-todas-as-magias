import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_race.dart';

class RacesRepository {
  static final RacesRepository _instance = RacesRepository._internal();

  factory RacesRepository() {
    return _instance;
  }

  RacesRepository._internal();

  List<DndRace>? _cachedRaces;

  Future<List<DndRace>> getRaces() async {
    if (_cachedRaces != null) {
      return _cachedRaces!;
    }

    final api = DndApiService();
    _cachedRaces = await api.fetchRace();

    return _cachedRaces!;
  }
}
