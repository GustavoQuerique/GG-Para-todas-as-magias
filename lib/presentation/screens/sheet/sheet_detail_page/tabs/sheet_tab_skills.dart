///TODO: adicionar os testes de resistência
///percepção passiva,
///e outras proficiencias e linguas

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';

class SheetTabSkills extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabSkills({super.key, required this.sheet});

  @override
  State<SheetTabSkills> createState() => _SheetTabSkillsState();
}

class _SheetTabSkillsState extends State<SheetTabSkills> {
  Widget buildSkill({
    required String name,
    required int attributeMod,
  }) {
    final sheet = widget.sheet;

    final isProficient = sheet.proficientSkills.contains(name);

    final total = attributeMod + (isProficient ? sheet.proficiencyBonus : 0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isProficient
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isProficient,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  sheet.proficientSkills.add(name);
                } else {
                  sheet.proficientSkills.remove(name);
                }
                sheet.save();
              });
            },
          ),
          Expanded(
            child: Text(name),
          ),
          Text(
            total >= 0 ? "+$total" : "$total",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCard({required Widget child}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return SafeArea(
      child: buildCard(
        child: ListView(
          shrinkWrap: true,
          children: [
            buildSkill(name: "Acrobacia", attributeMod: sheet.dexterityMod),
            buildSkill(name: "Arcanismo", attributeMod: sheet.intelligenceMod),
            buildSkill(name: "Atletismo", attributeMod: sheet.strengthMod),
            buildSkill(name: "Atuação", attributeMod: sheet.charismaMod),
            buildSkill(name: "Blefar", attributeMod: sheet.charismaMod),
            buildSkill(name: "Furtividade", attributeMod: sheet.dexterityMod),
            buildSkill(name: "História", attributeMod: sheet.intelligenceMod),
            buildSkill(name: "Intimidação", attributeMod: sheet.charismaMod),
            buildSkill(name: "Intuição", attributeMod: sheet.wisdomMod),
            buildSkill(name: "Investigação", attributeMod: sheet.wisdomMod),
            buildSkill(
              name: "Lidar com Animais",
              attributeMod: sheet.wisdomMod,
            ),
            buildSkill(name: "Medicina", attributeMod: sheet.wisdomMod),
            buildSkill(name: "Natureza", attributeMod: sheet.intelligenceMod),
            buildSkill(name: "Percepção", attributeMod: sheet.wisdomMod),
            buildSkill(name: "Persuasão", attributeMod: sheet.charismaMod),
            buildSkill(
              name: "Prestidigitação",
              attributeMod: sheet.dexterityMod,
            ),
            buildSkill(name: "Religião", attributeMod: sheet.intelligenceMod),
            buildSkill(name: "Sobrevivência", attributeMod: sheet.wisdomMod),
          ],
        ),
      ),
    );
  }
}
