///TODO: se possivel adicionar uma opção de gerar
///um personagem completamente aleatorio;
///mas primeiro preciso terminar os modelos das tabs.

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'sheet_detail_page/sheet_detail_page.dart';

class SheetViewerPage extends StatelessWidget {
  const SheetViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<CharacterSheet>('sheets');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Fichas"),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<CharacterSheet> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma ficha criada ainda",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final sheet = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(sheet.name),
                  subtitle: Text(
                    "${sheet.raceIndex ?? 'Raça'} • "
                    "${sheet.classIndex ?? 'Classe'} • "
                    "Nível ${sheet.level}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SheetDetailPage(sheet: sheet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSheet = CharacterSheet.empty();
          await box.add(newSheet);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SheetDetailPage(sheet: newSheet),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
