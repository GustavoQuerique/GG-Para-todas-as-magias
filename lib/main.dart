import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/core/theme/app_theme.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/local/api_cache_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_class.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/dnd_race.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_item.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/class_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/races_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spells/spell_list_page.dart';
import 'package:hive_flutter/adapters.dart';

import 'models/character_sheet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(SpellModelAdapter());
  Hive.registerAdapter(DndClassAdapter());
  Hive.registerAdapter(DndRaceAdapter());
  Hive.registerAdapter(CharacterSheetAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(WeightUnitAdapter());

  await Hive.openBox<SpellModel>('favorites');
  await Hive.openBox<SpellModel>('spells');
  await Hive.openBox<SpellModel>('spells_cache');
  await Hive.openBox<CharacterSheet>('sheets');
  await Hive.openBox<DndClass>('classes');
  await Hive.openBox<DndRace>('races');

  final apiCacheService = ApiCacheService(
    classRepository: ClassRepository(),
    spellRepository: SpellRepository(),
    raceRepository: RacesRepository(),
  );

  await apiCacheService.initializeCache();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grimório Arcano',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: SpellListPage(),
    );
  }
}
