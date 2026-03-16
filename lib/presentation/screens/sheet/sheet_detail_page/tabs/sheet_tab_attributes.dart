///mudar a aparencia da tela, passando o valor dos atributos para baixo
import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/widgets/medieval_card.dart';

class SheetTabAttributes extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabAttributes({
    super.key,
    required this.sheet,
  });

  @override
  State<SheetTabAttributes> createState() => _SheetTabAttributesState();
}

class _SheetTabAttributesState extends State<SheetTabAttributes> {
  int getModifier(int value) {
    return ((value - 10) / 2).floor();
  }

  Widget buildAttributeCard(String label, int value, Function(int) onChanged) {
    final modifier = getModifier(value);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const Text("Mod"),
                    Text(
                      modifier >= 0 ? "+$modifier" : "$modifier",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: value.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (val) {
                      final parsed = int.tryParse(val) ?? 10;
                      onChanged(parsed);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildAttributeCard(
              "Força",
              sheet.strength,
              (v) => sheet.strength = v,
            ),
            buildAttributeCard(
              "Destreza",
              sheet.dexterity,
              (v) => sheet.dexterity = v,
            ),
            buildAttributeCard(
              "Constituição",
              sheet.constitution,
              (v) => sheet.constitution = v,
            ),
            buildAttributeCard(
              "Inteligência",
              sheet.intelligence,
              (v) => sheet.intelligence = v,
            ),
            buildAttributeCard(
              "Sabedoria",
              sheet.wisdom,
              (v) => sheet.wisdom = v,
            ),
            buildAttributeCard(
              "Carisma",
              sheet.charisma,
              (v) => sheet.charisma = v,
            ),
            const SizedBox(height: 20),

            MedievalCard(
              child: SizedBox(
                child: Column(
                  children: [
                    Text('Cálculo de Modificadores'),
                    Text(
                      '•Modificador = (Atributo - 10) ÷ 2 (arredondado para- baixo)'
                      '\n•Exemplo: 16 FOR = + 3 modificador'
                      '\n•Exemplo: 8 DES = - 1 modificador',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
