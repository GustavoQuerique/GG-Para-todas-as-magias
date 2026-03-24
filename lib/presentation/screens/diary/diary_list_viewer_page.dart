import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/diary/diary_model.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/diary/diary_detail_page/diary_detail_page.dart';

import 'package:hive_flutter/hive_flutter.dart';

class DiaryListViewerPage extends StatelessWidget {
  const DiaryListViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DiaryModel>('diaries');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Diários"),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<DiaryModel> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text("Nenhum diário de aventura ainda."),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final diary = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.book, color: Colors.brown),
                  title: Text(diary.title),
                  subtitle: Text("${diary.entries.length} anotações"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiaryDetailPage(diary: diary),
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
        onPressed: () => _createNewDiary(context, box),
        child: const Icon(Icons.add_chart),
      ),
    );
  }

  void _createNewDiary(BuildContext context, Box<DiaryModel> box) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Diário"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Nome do Personagem ou Campanha",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final newDiary = DiaryModel.empty(controller.text);
                await box.add(newDiary);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }
}
