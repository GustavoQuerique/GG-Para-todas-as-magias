import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/local/favorites_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/memory/spell_model.dart';

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
  bool isFavorite = false;
  final DndApiService api = DndApiService();

  Map<String, dynamic>? spell;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSpell();
  }

  Future<void> loadSpell() async {
    final data = await api.fetchSpellsDetail(widget.spellIndex);

    setState(() {
      spell = data;
      isFavorite = favoritesService.isFavorite(data['index']);
      isLoading = false;
    });
  }

  @override
  Widget _info(String title, String value) {
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
              final index = spell!['index'];

              if (isFavorite) {
                favoritesService.removeFavorite(spell!['index']);
              } else {
                favoritesService.addFavorite(
                  SpellModel(
                    index: spell!['index'],
                    name: spell!['name'],
                    school: spell!['school']['name'],
                    level: spell!['level'],
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spell!['name'],
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  _info('Nível', spell!['level'].toString()),
                  _info('Escola', spell!['school']['name']),
                  _info('Alcance', spell!['range']),
                  _info('Duração', spell!['duration']),
                  _info(
                    'Concentração',
                    spell!['concentration'] ? 'Sim' : 'Não',
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
                    spell!['desc'].length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(spell!['desc'][i]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
