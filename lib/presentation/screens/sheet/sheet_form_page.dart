// ///TODO: Preciso arruamr o espaçamento entre as informação
// ///também melhorar a visibilidade do "Atributos", talvez dar um espaçamento entre eles
//
// import 'package:flutter/material.dart';
// import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
//
// class SheetFormPage extends StatefulWidget {
//   const SheetFormPage({super.key});
//
//   @override
//   State<SheetFormPage> createState() => _SheetFormPageState();
// }
//
// class _SheetFormPageState extends State<SheetFormPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final nameController = TextEditingController();
//   final raceController = TextEditingController();
//   final classController = TextEditingController();
//   final backgroundController = TextEditingController();
//   final alignmentController = TextEditingController();
//
//   int level = 1;
//
//   int strength = 10;
//   int dexterity = 10;
//   int constitution = 10;
//   int intelligence = 10;
//   int wisdom = 10;
//   int charisma = 10;
//
//   void saveSheet() {
//     if (!_formKey.currentState!.validate()) return;
//
//     final sheet = SheetModel(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: nameController.text,
//       race: raceController.text,
//       characterClass: classController.text,
//       background: backgroundController.text,
//       alignment: alignmentController.text,
//       level: level,
//       experience: 0,
//       strength: strength,
//       dexterity: dexterity,
//       constitution: constitution,
//       intelligence: intelligence,
//       wisdom: wisdom,
//       charisma: charisma,
//       currentHp: 10,
//       maxHp: 10,
//       tempHp: 0,
//       armorClass: 10,
//       initiative: 0,
//       speed: 30,
//       proficientSkills: [],
//       preparedSpells: [],
//       inventory: [],
//     );
//
//     Navigator.pop(context, sheet);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Criar Personagem")),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             TextFormField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Nome"),
//               validator: (value) =>
//                   value == null || value.isEmpty ? "Obrigatório" : null,
//             ),
//             TextFormField(
//               controller: raceController,
//               decoration: const InputDecoration(labelText: "Raça"),
//             ),
//             TextFormField(
//               controller: classController,
//               decoration: const InputDecoration(labelText: "Classe"),
//             ),
//             TextFormField(
//               controller: backgroundController,
//               decoration: const InputDecoration(labelText: "Antecedente"),
//             ),
//             TextFormField(
//               controller: alignmentController,
//               decoration: const InputDecoration(labelText: "Alinhamento"),
//             ),
//             const SizedBox(height: 20),
//             const Text("Atributos"),
//             buildAttributeField("Força", strength, (v) => strength = v),
//             buildAttributeField("Destreza", dexterity, (v) => dexterity = v),
//             buildAttributeField(
//               "Constituição",
//               constitution,
//               (v) => constitution = v,
//             ),
//             buildAttributeField(
//               "Inteligência",
//               intelligence,
//               (v) => intelligence = v,
//             ),
//             buildAttributeField("Sabedoria", wisdom, (v) => wisdom = v),
//             buildAttributeField("Carisma", charisma, (v) => charisma = v),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: saveSheet,
//               child: const Text("Salvar"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildAttributeField(String label, int value, Function(int) onChanged) {
//     return Row(
//       children: [
//         Expanded(child: Text(label)),
//         SizedBox(
//           width: 80,
//           child: TextFormField(
//             initialValue: value.toString(),
//             keyboardType: TextInputType.number,
//             onChanged: (val) => onChanged(int.tryParse(val) ?? 10),
//           ),
//         ),
//       ],
//     );
//   }
// }
