import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/core/theme/app_theme.dart';

import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/diary/diary_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_class.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/dnd_race.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_item.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';

import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/splash/splash_screen.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(SpellModelAdapter());
  Hive.registerAdapter(DndClassAdapter());
  Hive.registerAdapter(DndRaceAdapter());
  Hive.registerAdapter(CharacterSheetAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(WeightUnitAdapter());
  Hive.registerAdapter(DiaryModelAdapter());
  Hive.registerAdapter(DiaryEntryAdapter());

  await Hive.openBox<SpellModel>('favorites');
  await Hive.openBox<SpellModel>('spells');
  await Hive.openBox<SpellModel>('spells_cached');
  await Hive.openBox<CharacterSheet>('sheets');
  await Hive.openBox<DndClass>('classes');
  await Hive.openBox<DndRace>('races');
  await Hive.openBox<DiaryModel>('diaries');

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
      home: const SplashScreen(),
    );
  }
}
