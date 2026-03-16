import 'package:hive/hive.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_race.dart';

class RacesRepository {
  static final RacesRepository _instance = RacesRepository._internal();

  factory RacesRepository() {
    return _instance;
  }

  RacesRepository._internal();

  final DndApiService api = DndApiService();

  Future<List<DndRace>> getRaces() async {
    final box = await Hive.openBox<DndRace>("races");

    if (box.isNotEmpty) {
      return box.values.toList();
    }

    final races = await api.fetchRace();

    await box.addAll(races);

    return races;
  }

  Future<void> refreshRaces() async {
    final box = await Hive.openBox<DndRace>("races");

    try {
      final races = await api.fetchRace();

      await box.clear();
      await box.addAll(races);
    } catch (e) {
      print('Falha ao atualizar o repositorio de raças');
    }

    // await box.clear();
    //
    // final races = await api.fetchRace();
    //
    // await box.addAll(races);
  }
}
