import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/favorites/favorites_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spell_detail_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/action_button.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/bottom_panel_widget.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/circular_action_menu.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/spell_filter.dart';

import '../../data/datasources/remote/dnd_api_service.dart';

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
  List spells = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSpells();
  }

  Future<void> loadSpells() async {
    final data = await api.fetchSpells();
    setState(() {
      spells = data;
      isLoading = false;
    });
  }

  Future<void> fetchSpellsWithFilter({
    String? className,
    String? school,
    int? level,
  }) async {
    setState(() {
      isLoading = true;
    });

    final data = await api.fetchSpells(
      className: className,
      school: school,
      level: level,
    );

    setState(() {
      spells = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grimório Arcano'),
        actions: [
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
                    fetchSpellsWithFilter(
                      className: className,
                      school: school,
                      level: level,
                    );
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
                  onTap: () {},
                ),
                ActionButton(
                  icon: Icons.person,
                  label: 'Ficha',
                  onTap: () {},
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
            subtitle: Text('Index: ${spell['index']}'),
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
