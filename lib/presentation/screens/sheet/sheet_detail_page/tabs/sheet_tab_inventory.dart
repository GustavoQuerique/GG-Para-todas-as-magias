import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory_item.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/medieval_card.dart';

class SheetTabInventory extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabInventory({super.key, required this.sheet});

  @override
  State<SheetTabInventory> createState() => _SheetTabInventoryState();
}

class _SheetTabInventoryState extends State<SheetTabInventory> {
  void addItem() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final quantityController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adicionar Item"),
        content: MedievalCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),

              SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Peso (lb)"),
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantidade"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final weight = double.tryParse(weightController.text) ?? 0;
              final quantity = int.tryParse(quantityController.text) ?? 1;

              if (name.isNotEmpty) {
                setState(() {
                  widget.sheet.inventory.add(
                    InventoryItem(
                      name: name,
                      weight: weight,
                      quantity: quantity,
                    ),
                  );
                  widget.sheet.save();
                });
              }

              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deletar item?'),
            content: const Text(
              'Essa ação não pode ser desfeita. Deseja continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Deletar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // MOEDAS
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Moedas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _coinField("CP", sheet.copper, (v) {
                          sheet.copper = v;
                        }),
                        _coinField("SP", sheet.silver, (v) {
                          sheet.silver = v;
                        }),
                        _coinField("EP", sheet.electrum, (v) {
                          sheet.electrum = v;
                        }),
                        _coinField("GP", sheet.gold, (v) {
                          sheet.gold = v;
                        }),
                        _coinField("PP", sheet.platinum, (v) {
                          sheet.platinum = v;
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            //PESO
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Capacidade de Carga",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${sheet.currentWeight.toStringAsFixed(1)} lb / ${sheet.carryingCapacity} lb",
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: sheet.weightRatio.clamp(0, 1),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            //LISTA DE ITENS
            ...sheet.inventory.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return MedievalCard(
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    "Qtd: ${item.quantity} | ${item.totalWeight} lb",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      if (await _confirmDelete()) {
                        setState(() {
                          sheet.inventory.removeAt(index);
                          sheet.save();
                        });
                      }
                    },
                  ),
                ),
              );
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addItem,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _coinField(String label, int value, Function(int) onChanged) {
    final controller = TextEditingController(text: value.toString());

    return SizedBox(
      width: 55,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onSubmitted: (val) {
          final parsed = int.tryParse(val) ?? 0;
          setState(() {
            onChanged(parsed);
            widget.sheet.save();
          });
        },
      ),
    );
  }
}
