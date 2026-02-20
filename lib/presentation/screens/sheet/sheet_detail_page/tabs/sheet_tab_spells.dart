import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';

class SheetTabSpells extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabSpells({super.key, required this.sheet});

  @override
  State<SheetTabSpells> createState() => _SheetTabSpellsState();
}

class _SheetTabSpellsState extends State<SheetTabSpells> {
  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF334155)),
    );
  }

  void selectSpell(int level) async {
    final spells = await DndApiService().fetchSpells();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ListView.builder(
          itemCount: spells.length,
          itemBuilder: (_, index) {
            final spell = spells[index];

            return ListTile(
              title: Text(spell['name']),
              onTap: () {
                setState(() {
                  widget.sheet.spellsByLevel[level]!.add(
                    spell['index'],
                  ); // salva o index
                  widget.sheet.save();
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget buildSpellLevel(int level) {
    final spells = widget.sheet.spellsByLevel[level]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                level == 0 ? "Truques" : "Nível $level",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => selectSpell(level),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (spells.isEmpty)
            const Text(
              "Nenhuma magia adicionada",
              style: TextStyle(fontSize: 12),
            ),

          ...spells.map((spellIndex) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(spellIndex),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    spells.remove(spellIndex);
                    widget.sheet.save();
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            10,
            (level) => buildSpellLevel(level),
          ),
        ),
      ),
    );
  }
}
