import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/core/theme/app_theme.dart';
import 'package:guia_de_garlou_para_todas_as_magias/memory/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spell_list_page.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(SpellModelAdapter());

  await Hive.openBox<SpellModel>('favorites');
  await Hive.openBox<SpellModel>('spells');

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
