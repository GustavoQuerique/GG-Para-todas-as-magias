import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/create_spells/spell_creator.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/favorites/favorites_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_viewer_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spells/spell_detail_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/action_button.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/circular_action_menu.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/spell_filter.dart';

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
  bool showOnlyCustom = false;
  bool isSearching = false;

  final TextEditingController searchController = TextEditingController();
  final SpellRepository spellRepository = SpellRepository();

  List<SpellModel> spells = [];
  List<SpellModel> availableSpells = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    reloadSpells();
  }

  Future<void> reloadSpells() async {
    try {
      final customBox = await Hive.openBox<SpellModel>('spells');
      final cachedSpells = await spellRepository.getSpells();

      List<SpellModel> allSpells = [
        ...customBox.values,
        ...cachedSpells,
      ];

      List<SpellModel> filtered = allSpells.where((spell) {
        if (selectedLevel != null && spell.level != selectedLevel) return false;

        if (selectedSchool != null &&
            spell.school.toLowerCase() != selectedSchool?.toLowerCase()) {
          return false;
        }

        if (showOnlyCustom && !spell.index.startsWith('custom_')) {
          return false;
        }
        return true;
      }).toList();

      if (!mounted) return;

      setState(() {
        spells = filtered;
        spells.sort((a, b) => a.name.compareTo(b.name));
        availableSpells = List.from(spells);
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar magias: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching ? _buildSearchBar() : const Text('Grimório Arcano'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(
                () {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    searchController.clear();
                    searchSpell('');
                  }
                },
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SpellFilter(
                  initialClass: selectedClass,
                  initialSchool: selectedSchool,
                  initialLevel: selectedLevel,
                  initialOnlyCustom: showOnlyCustom,
                  onApply: (className, school, level, isCustom) {
                    setState(() {
                      selectedClass = className;
                      selectedSchool = school;
                      selectedLevel = level;
                      showOnlyCustom = isCustom;
                    });
                    reloadSpells();
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildSpellList(),
                Positioned(
                  bottom: -50,
                  right: 125,

                  ///Talvez vale a pena mover isso para outro lugar
                  child: SafeArea(
                    child: CircularActionMenu(
                      actions: [
                        ActionButton(
                          icon: Icons.star,
                          label: 'Favoritos',
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
                                builder: (_) => const SheetViewerPage(),
                              ),
                            );
                          },
                        ),
                        ActionButton(
                          icon: Icons.book,
                          label: 'Diário',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
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

    if (spells.isEmpty) {
      return const Center(child: Text("Nenhuma magia encontrada"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: spells.length,
      itemBuilder: (context, index) {
        final spell = spells[index];

        return Card(
          child: ListTile(
            title: Text(spell.name),
            subtitle: Text('Level: ${spell.level} • ${spell.school}'),
            trailing: spell.index.startsWith('custom_')
                ? const Icon(
                    Icons.bookmark,
                    color: Colors.purpleAccent,
                  )
                : _getSchoolIcon(spell.school, Colors.grey[400]!),
            onTap: () async {
              FocusScope.of(context).unfocus();

              final deleted = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => SpellDetailPage(
                    spellIndex: spell.index,
                  ),
                ),
              );

              if (deleted == true) {
                reloadSpells();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.search_outlined),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Pesquisar magia...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: searchSpell,
            ),
          ),
        ],
      ),
    );
  }

  void searchSpell(String query) {
    final input = query.toLowerCase();

    final suggestions = availableSpells.where((spell) {
      return spell.name.toLowerCase().contains(input);
    }).toList();

    setState(() {
      spells = suggestions;
    });
  }

  Widget _getSchoolIcon(String school, Color color) {
    switch (school.toLowerCase()) {
      case 'evocation':
        return Icon(Icons.local_fire_department, color: color);
      case 'conjuration':
        return Icon(Icons.auto_fix_high, color: color);
      case 'abjuration':
        return Icon(Icons.shield, color: color);
      case 'divination':
        return Icon(Icons.remove_red_eye, color: color);
      case 'enchantment':
        return Icon(Icons.favorite, color: color);
      case 'illusion':
        return Icon(Icons.auto_awesome_motion, color: color);
      case 'necromancy':
        return FaIcon(
          FontAwesomeIcons.skull,
          color: color,
          size: 20,
        ); // FontAwesome
      case 'transmutation':
        return FaIcon(
          FontAwesomeIcons.atom,
          color: color,
          size: 20,
        ); // FontAwesome
      default:
        return Icon(Icons.menu_book_outlined, color: color);
    }
  }
}
