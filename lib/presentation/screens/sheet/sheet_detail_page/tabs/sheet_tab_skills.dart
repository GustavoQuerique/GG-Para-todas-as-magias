import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';

class SheetTabSkills extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabSkills({super.key, required this.sheet});

  @override
  State<SheetTabSkills> createState() => _SheetTabSkillsState();
}

class _SheetTabSkillsState extends State<SheetTabSkills> {
  Widget buildSkill({
    required String name,
    required String attributeLabel,
    required int attributeMod,
  }) {
    final sheet = widget.sheet;
    final isProficient = sheet.proficientSkills.contains(name);
    final total = attributeMod + (isProficient ? sheet.proficiencyBonus : 0);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          if (isProficient) {
            sheet.proficientSkills.remove(name);
          } else {
            sheet.proficientSkills.add(name);
          }
          sheet.save();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                total >= 0 ? "+$total" : "$total",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isProficient
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Text(
              "($attributeLabel)",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          buildSectionTitle("Testes de Resistência"),

          buildSkill(
            name: "Força",
            attributeLabel: "FOR",
            attributeMod: sheet.strengthMod,
          ),
          buildSkill(
            name: "Destreza",
            attributeLabel: "DES",
            attributeMod: sheet.dexterityMod,
          ),
          buildSkill(
            name: "Constituição",
            attributeLabel: "CON",
            attributeMod: sheet.constitutionMod,
          ),
          buildSkill(
            name: "Inteligência",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Sabedoria",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),
          buildSkill(
            name: "Carisma",
            attributeLabel: "CAR",
            attributeMod: sheet.charismaMod,
          ),

          const Divider(height: 32),

          buildSectionTitle("Perícias"),

          buildSkill(
            name: "Acrobacia",
            attributeLabel: "DES",
            attributeMod: sheet.dexterityMod,
          ),
          buildSkill(
            name: "Arcanismo",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Atletismo",
            attributeLabel: "FOR",
            attributeMod: sheet.strengthMod,
          ),
          buildSkill(
            name: "Atuação",
            attributeLabel: "CAR",
            attributeMod: sheet.charismaMod,
          ),
          buildSkill(
            name: "Blefar",
            attributeLabel: "CAR",
            attributeMod: sheet.charismaMod,
          ),
          buildSkill(
            name: "Furtividade",
            attributeLabel: "DES",
            attributeMod: sheet.dexterityMod,
          ),
          buildSkill(
            name: "História",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Intimidação",
            attributeLabel: "CAR",
            attributeMod: sheet.charismaMod,
          ),
          buildSkill(
            name: "Intuição",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),
          buildSkill(
            name: "Investigação",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Lidar com Animais",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),
          buildSkill(
            name: "Medicina",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),
          buildSkill(
            name: "Natureza",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Percepção",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),
          buildSkill(
            name: "Persuasão",
            attributeLabel: "CAR",
            attributeMod: sheet.charismaMod,
          ),
          buildSkill(
            name: "Prestidigitação",
            attributeLabel: "DES",
            attributeMod: sheet.dexterityMod,
          ),
          buildSkill(
            name: "Religião",
            attributeLabel: "INT",
            attributeMod: sheet.intelligenceMod,
          ),
          buildSkill(
            name: "Sobrevivência",
            attributeLabel: "SAB",
            attributeMod: sheet.wisdomMod,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
