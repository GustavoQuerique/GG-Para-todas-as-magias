import 'package:hive/hive.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_class.dart';

class ClassRepository {
  static final ClassRepository _instance = ClassRepository._internal();

  factory ClassRepository() {
    return _instance;
  }

  ClassRepository._internal();

  final DndApiService api = DndApiService();

  Future<List<DndClass>> getClasses() async {
    final box = await Hive.openBox<DndClass>("classes");

    if (box.isNotEmpty) {
      return box.values.toList();
    }

    final classes = await api.fetchClasses();

    await box.addAll(classes);

    return classes;
  }

  Future<void> refreshClasses() async {
    final box = await Hive.openBox<DndClass>("classes");

    try {
      final classes = await api.fetchClasses();

      await box.clear();
      await box.addAll(classes);
    } catch (e) {
      print("Falha ao atualizar classes, mantendo cache");
    }
  }
}
