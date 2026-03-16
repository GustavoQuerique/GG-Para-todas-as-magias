import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/local/favorites_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/spell_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';

import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/action_button.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/buttons/circular_action_menu.dart';

import 'package:hive/hive.dart';

class SpellDetailPage extends StatefulWidget {
  final String spellIndex;

  const SpellDetailPage({
    super.key,
    required this.spellIndex,
  });

  @override
  State<SpellDetailPage> createState() => _SpellDetailPageState();
}

class _SpellDetailPageState extends State<SpellDetailPage> {
  final favoritesService = FavoritesService();
  final SpellRepository spellRepository = SpellRepository();

  bool isFavorite = false;
  SpellModel? spell;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSpell();
  }

  Future<void> loadSpell() async {
    try {
      SpellModel? loadedSpell;

      if (widget.spellIndex.startsWith('custom_')) {
        final box = Hive.box<SpellModel>('spells');
        loadedSpell = box.get(widget.spellIndex);
      } else {
        loadedSpell = await spellRepository.getSpellByIndex(widget.spellIndex);
      }

      if (!mounted) return;

      setState(() {
        spell = loadedSpell;
        isFavorite =
            loadedSpell != null &&
            favoritesService.isFavorite(loadedSpell.index);
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Erro ao carregar magia: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteSpell() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar magia'),
        content: const Text(
          'Essa ação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final box = Hive.box<SpellModel>('spells');
    await box.delete(spell!.index);
    favoritesService.removeFavorite(spell!.index);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget _info(String title, {String? value = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$title: $value'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Magia'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              final index = spell!.index;

              if (isFavorite) {
                favoritesService.removeFavorite(index);
              } else {
                favoritesService.addFavorite(
                  SpellModel(
                    index: spell!.index,
                    name: spell!.name,
                    school: spell!.school,
                    level: spell!.level,
                    concentration: spell!.concentration,
                  ),
                );
              }

              setState(() {
                isFavorite = !isFavorite;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : spell == null
          ? const Center(child: Text('Erro ao carregar magia'))
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              spell!.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 16),

                            _info('Nível', value: spell!.level.toString()),
                            _info('Escola', value: spell!.school),
                            _info('Alcance', value: spell!.range?.toString()),
                            _info(
                              'Duração',
                              value: spell!.duration?.toString(),
                            ),
                            _info(
                              'Concentração',
                              value: spell!.concentration ? 'Sim' : 'Não',
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Descrição',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            ...List.generate(
                              spell!.description.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(spell!.description[i]),
                              ),
                            ),
                          ],
                        ),
                        if (spell!.index.startsWith('custom_'))
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularActionMenu(
                                actions: [
                                  ActionButton(
                                    icon: Icons.delete_outline,
                                    label: 'Deletar Magia',
                                    onTap: _deleteSpell,
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
