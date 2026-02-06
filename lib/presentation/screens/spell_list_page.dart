import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/memory/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/create_spells/spell_creator.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/favorites/favorites_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_creator.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spell_detail_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/buttons/action_button.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/buttons/circular_action_menu.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/spell_filter.dart';
import 'package:hive/hive.dart';

class SpellListPage extends StatefulWidget {
  const SpellListPage({super.key});

  @override
  State<SpellListPage> createState() => _SpellListPageState();
}

class _SpellListPageState extends State<SpellListPage> {
  String? selectedClass;
  String? selectedSchool;
  int? selectedLevel;

  final DndApiService api = DndApiService();
  List<Map<String, dynamic>> spells = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    reloadSpells();
  }

  Future<void> reloadSpells() async {
    setState(() {
      isLoading = true;
    });

    // API
    final apiSpells = await api.fetchSpells(
      className: selectedClass,
      school: selectedSchool,
      level: selectedLevel,
    );

    // (Hive)
    final customBox = Hive.box<SpellModel>('spells');

    final customSpells = customBox.values.map((spell) {
      return {
        'index': spell.index,
        'name': spell.name,
        'school': {'name': spell.school},
        'level': spell.level,
        'isCustom': true,
      };
    }).toList();

    // 3️⃣ junta tudo
    setState(() {
      spells = [
        ...customSpells,
        ...apiSpells,
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grimório Arcano'),
        actions: [
          //Filtros
          IconButton(
            icon: Icon(Icons.filter_list_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SpellFilter(
                  initialClass: selectedClass,
                  initialSchool: selectedSchool,
                  initialLevel: selectedLevel,
                  onApply: (className, school, level) {
                    setState(() {
                      selectedClass = className;
                      selectedSchool = school;
                      selectedLevel = level;
                    });
                    reloadSpells();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildSpellList(),
          Positioned(
            bottom: -50,
            right: 125,
            child: CircularActionMenu(
              actions: [
                ActionButton(
                  icon: Icons.star,
                  label: 'Favoritoss',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.auto_fix_high,
                  label: 'Criar Magia',
                  onTap: () async {
                    final created = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SpellCreator(),
                      ),
                    );

                    if (created == true) {
                      reloadSpells();
                    }
                  },
                ),
                ActionButton(
                  icon: Icons.person,
                  label: 'Ficha',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SheetCreator(),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.book,
                  label: 'Díario',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: spells.length,
      itemBuilder: (context, index) {
        final spell = spells[index];

        return Card(
          child: ListTile(
            title: Text(spell['name']),
            subtitle: Text(
              spell['isCustom'] == true
                  ? 'Magia personalizada'
                  : 'Index: ${spell['index']}',
            ),
            trailing: const Icon(Icons.menu_book),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpellDetailPage(
                    spellIndex: spell['index'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
