import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_class.dart';

class ClassRepository {
  // Instância única
  static final ClassRepository _instance = ClassRepository._internal();

  // Construtor factory
  factory ClassRepository() {
    return _instance;
  }

  // Construtor privado
  ClassRepository._internal();

  List<DndClass>? _cachedClasses;

  Future<List<DndClass>> getClasses() async {
    if (_cachedClasses != null) {
      return _cachedClasses!;
    }

    final api = DndApiService();
    _cachedClasses = await api.fetchClasses();

    return _cachedClasses!;
  }
}
