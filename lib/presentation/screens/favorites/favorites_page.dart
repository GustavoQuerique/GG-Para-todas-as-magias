import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/spell_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final favoritesBox = Hive.box<SpellModel>('favorites');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, Box<SpellModel> box, _) {
          if (box.values.isEmpty) {
            return const Center(
              child: Text('Nenhuma Magia Favorita'),
            );
          }
          final favorites = box.values.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final spell = favorites[index];

              return Card(
                child: ListTile(
                  title: Text(spell.name),
                  subtitle: Text(
                    '${spell.school} | Nível ${spell.level}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      box.delete(spell.index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
