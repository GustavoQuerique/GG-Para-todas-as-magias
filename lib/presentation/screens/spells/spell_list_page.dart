import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/spell_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/create_spells/spell_creator.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/favorites/favorites_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_viewer_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spells/spell_detail_page.dart';
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

  final TextEditingController searchController = TextEditingController();
  final SpellRepository spellRepository = SpellRepository();

  List<SpellModel> spells = [];
  List<SpellModel> availableSpells = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData(); // Criamos uma função mestre para gerenciar o fluxo
  }

  Future<void> _initializeData() async {
    // Primeiro, carrega o que já existe no cache (para não deixar o usuário esperando)
    await reloadSpells();

    // Se a lista estiver vazia, ou se quiser atualizar sempre ao abrir:
    if (availableSpells.isEmpty) {
      setState(() => isLoading = true);
    }

    try {
      // Tenta atualizar os dados da API em segundo plano
      await spellRepository.refreshSpells();

      // Quando terminar o download, recarrega a lista para mostrar as novidades
      await reloadSpells();
    } catch (e) {
      print("Erro ao sincronizar com API: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> reloadSpells() async {
    try {
      final customBox = await Hive.openBox<SpellModel>('spells_cached');

      final cachedSpells = await spellRepository.getSpells();

      List<SpellModel> filtered = cachedSpells.where((spell) {
        if (selectedLevel != null && spell.level != selectedLevel) return false;

        if (selectedSchool != null &&
            spell.school.toLowerCase() != selectedSchool?.toLowerCase()) {
          return false;
        }
        return true;
      }).toList();

      if (!mounted) return;

      setState(() {
        // Combinamos as magias criadas manualmente ('spells') com as da API ('filtered')
        spells = [
          ...customBox.values,
          ...filtered,
        ];

        spells.sort((a, b) => a.name.compareTo(b.name));

        availableSpells = List.from(spells);
        isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar magias: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grimório Arcano'),
        actions: [
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
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
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
            subtitle: Text('Level: ${spell.level}'),
            trailing: Icon(
              spell.index.startsWith('custom_')
                  ? Icons.bookmark
                  : Icons.menu_book_outlined,
            ),
            onTap: () async {
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
}
