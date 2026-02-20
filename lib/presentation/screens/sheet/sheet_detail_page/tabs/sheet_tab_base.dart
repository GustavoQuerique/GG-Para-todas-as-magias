import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/inline_editable_field.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/medieval_card.dart';

class SheetTabBase extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabBase({super.key, required this.sheet});

  @override
  State<SheetTabBase> createState() => _SheetTabBaseState();
}

class _SheetTabBaseState extends State<SheetTabBase> {
  CharacterSheet get sheet => widget.sheet;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// NOME DO PERSONAGEM
          MedievalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nome do Personagem",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 8),

                InlineEditableField(
                  value: sheet.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      sheet.name = value;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ///INFORMAÇÕES PRINCIPAIS
          MedievalCard(
            child: Column(
              children: [
                _buildInfoRow(
                  title: "Nível",
                  value: sheet.level.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.level = int.tryParse(val) ?? sheet.level;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildInfoRow(
                  title: "Raça",
                  value: sheet.raceIndex ?? "Não definida",
                  onChanged: (val) {
                    setState(() {
                      sheet.raceIndex = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildInfoRow(
                  title: "Classe",
                  value: sheet.classIndex ?? "Não definida",
                  onChanged: (val) {
                    setState(() {
                      sheet.classIndex = val;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildInfoRow(
                  title: "Alinhamento",
                  value: sheet.alignment ?? "Não definido",
                  onChanged: (val) {
                    setState(() {
                      sheet.alignment = val;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// VIDA
          MedievalCard(
            child: Column(
              children: [
                _buildInfoRow(
                  title: "Classe de Armadura",
                  value: sheet.armorClass.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.armorClass = int.tryParse(val) ?? sheet.armorClass;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildInfoRow(
                  title: "Vida Máxima",
                  value: sheet.maxHp.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.maxHp = int.tryParse(val) ?? sheet.maxHp;
                      sheet.save();
                    });
                  },
                ),

                const Divider(),

                _buildInfoRow(
                  title: "Vida Atual",
                  value: sheet.currentHp.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      sheet.currentHp = int.tryParse(val) ?? sheet.currentHp;
                      sheet.save();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          SizedBox(
            width: 120,
            child: InlineEditableField(
              value: value,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
