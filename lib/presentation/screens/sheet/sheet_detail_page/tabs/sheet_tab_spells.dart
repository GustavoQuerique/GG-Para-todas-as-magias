///TOODO: trocar a forma de pesquisa/adicionar magia
///fazer as magias reativas a lista (tocou nela vai para descrição)
/// adicionar slotes de maigas disponiveis baseado no lv

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/repositories/spell_slot_repository.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/spells/spell_detail_page.dart';
import 'package:guia_de_garlou_para_todas_as_magias/data/datasources/remote/dnd_api_service.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/medieval_card.dart';

class SheetTabSpells extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabSpells({super.key, required this.sheet});

  @override
  State<SheetTabSpells> createState() => _SheetTabSpellsState();
}

class _SheetTabSpellsState extends State<SheetTabSpells> {
  final spellSlotRepository = SpellSlotRepository();
  final api = DndApiService();

  Map<int, int> availableSlots = {};

  @override
  void initState() {
    super.initState();
    _loadSpellSlots();
  }

  Future<void> _loadSpellSlots() async {
    if (widget.sheet.classIndex == null) return;

    final slots = await spellSlotRepository.getSpellSlots(
      classIndex: widget.sheet.classIndex!,
      level: widget.sheet.level,
    );

    setState(() {
      availableSlots = slots;
    });
  }

  void selectSpell(int level) async {
    final spells = await api.fetchSpells(level: level);

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
                  widget.sheet.spellsByLevel[level]!.add(spell['index']);
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
    final totalSlots = availableSlots[level] ?? 0;
    final usedSlots = widget.sheet.spellSlots[level] ?? 0;

    final remaining = totalSlots - usedSlots;

    if (level > 0 && totalSlots == 0) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MedievalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
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
                if (level > 0)
                  TextButton(
                    child: Text('Resetar'),
                    onPressed: () {
                      setState(() {
                        widget.sheet.spellSlots[level] = 0;
                        widget.sheet.save();
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => selectSpell(level),
                ),
              ],
            ),

            /// SLOT BAR (somente se não for truque)
            if (level > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Slots: $remaining / $totalSlots"),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: totalSlots == 0 ? 0 : usedSlots / totalSlots,
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            if (spells.isEmpty)
              const Text(
                "Nenhuma magia adicionada",
                style: TextStyle(fontSize: 12),
              ),

            ...spells.map((spellIndex) {
              ///Abri descrição da magia
              return MedievalCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(spellIndex),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpellDetailPage(spellIndex: spellIndex),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (level > 0)
                        IconButton(
                          icon: const Icon(Icons.flash_on),
                          onPressed: () {
                            if (remaining <= 0) return;

                            setState(() {
                              widget.sheet.spellSlots[level] = usedSlots + 1;
                              widget.sheet.save();
                            });
                          },
                        ),

                      if (level > 0)
                        IconButton(
                          icon: Icon(Icons.restart_alt),
                          onPressed: () {
                            if (remaining == totalSlots) return;

                            setState(() {
                              widget.sheet.spellSlots[level] = usedSlots - 1;
                              widget.sheet.save();
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            spells.remove(spellIndex);
                            widget.sheet.save();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          10,
          (level) => buildSpellLevel(level),
        ),
      ),
    );
  }
}
