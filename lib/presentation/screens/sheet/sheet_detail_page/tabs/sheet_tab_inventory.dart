///TODO: fazer com que os itens do grid afetem a capacidade de carga
///Almentar o tamanho do texto dentro do grid
///tornar os itens tocaveis para abrir uma aba de descrição
///ESSE ARQUIVO DA MUITO GRANDE, VAMOS CRIAR UM NOVO SO PARA OS WIDGETS DELE
///talvez colocar fome/sistema de comida

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_container.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_item_instance.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_manager.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_item.dart';

class SheetTabInventory extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabInventory({super.key, required this.sheet});

  @override
  State<SheetTabInventory> createState() => _SheetTabInventoryState();
}

class _SheetTabInventoryState extends State<SheetTabInventory> {
  late InventoryManager inventoryManager;
  final GlobalKey _gridKey = GlobalKey();
  InventoryItemInstance? draggingItem;
  Offset? dragOffset;
  Offset? dragPosition;
  InventoryType selectedType = InventoryType.mediumBackpack;

  @override
  void initState() {
    super.initState();
    inventoryManager = InventoryManager(InventoryType.mediumBackpack);

    if (widget.sheet.inventoryGridItems.isNotEmpty) {
      inventoryManager.importItems(widget.sheet.inventoryGridItems);
    }
  }

  // ADICIONAR ITEM AO GRID
  void addItem() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final quantityController = TextEditingController(text: "1");
    final widthController = TextEditingController(text: "1");
    final heightController = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adicionar Item"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Peso (lb)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: "Quantidade"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: "Largura (grid)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Altura (grid)"),
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
              final width = int.tryParse(widthController.text) ?? 1;
              final height = int.tryParse(heightController.text) ?? 1;

              if (name.isEmpty) return;

              final newItem = InventoryItemInstance(
                baseItem: InventoryItem(
                  name: name,
                  weight: weight,
                  quantity: quantity,
                ),
                width: width,
                height: height,
              );

              final added = inventoryManager.addItem(newItem);

              if (!added) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Não há espaço suficiente no inventário."),
                  ),
                );
              }

              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  //
  // UI
  //
  @override
  Widget build(BuildContext context) {
    final sheet = widget.sheet;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //
              // MOEDAS
              //
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

              const SizedBox(height: 20),

              //
              // CAPACIDADE
              //
              ValueListenableBuilder<WeightUnit>(
                valueListenable: sheet.weightUnitNotifier,
                builder: (context, unit, _) {
                  final current = sheet.convertWeight(sheet.currentWeight);
                  final capacity = sheet.convertWeight(sheet.carryingCapacity);

                  return Card(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("lb"),
                              Switch(
                                value: unit == WeightUnit.kg,
                                onChanged: (_) => sheet.toggleWeightUnit(),
                              ),
                              const Text("kg"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${current.toStringAsFixed(1)} ${sheet.weightLabel} / "
                            "${capacity.toStringAsFixed(1)} ${sheet.weightLabel}",
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: sheet.weightRatio.clamp(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              //
              // INVENTÁRIO
              //
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Inventário",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<InventoryType>(
                    value: selectedType,
                    onChanged: (newType) {
                      if (newType != null) {
                        _changeBackpack(newType);
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: InventoryType.smallBackpack,
                        child: Text("Pequena"),
                      ),
                      DropdownMenuItem(
                        value: InventoryType.mediumBackpack,
                        child: Text("Média"),
                      ),
                      DropdownMenuItem(
                        value: InventoryType.largeBackpack,
                        child: Text("Grande"),
                      ),
                      DropdownMenuItem(
                        value: InventoryType.bagOfHolding,
                        child: Text("Bag of Holding"),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 400,
                child: buildInventoryGrid(),
              ),
            ],
          ),
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

  //
  // GRID
  //
  Widget buildInventoryGrid() {
    final grid = inventoryManager.grid;
    final rows = grid.container.rows;
    final cols = grid.container.columns;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / cols;

        return Stack(
          key: _gridKey,
          children: [
            // GRID BASE
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows * cols,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ cols;
                final col = index % cols;

                return GestureDetector(
                  onTap: () {
                    if (draggingItem != null) {
                      final moved = inventoryManager.moveItem(
                        draggingItem!,
                        row,
                        col,
                      );

                      if (moved) {
                        setState(() {
                          draggingItem = null;
                        });
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade700),
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),

            // ITENS AGRUPADOS
            ..._buildPositionedItems(cellSize),
          ],
        );
      },
    );
  }

  List<Widget> _buildPositionedItems(double cellSize) {
    final grid = inventoryManager.grid;
    final rows = grid.container.rows;
    final cols = grid.container.columns;

    final List<Widget> widgets = [];
    final Set<InventoryItemInstance> renderedItems = {};

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final item = grid.grid[r][c];

        if (item != null && !renderedItems.contains(item)) {
          renderedItems.add(item);

          final isDragging = draggingItem == item;

          widgets.add(
            Positioned(
              left: isDragging
                  ? dragPosition!.dx - dragOffset!.dx
                  : item.posY * cellSize,
              top: isDragging
                  ? dragPosition!.dy - dragOffset!.dy
                  : item.posX * cellSize,
              width: item.width * cellSize,
              height: item.height * cellSize,
              child: GestureDetector(
                onPanStart: (details) {
                  final box =
                      _gridKey.currentContext!.findRenderObject() as RenderBox;

                  final localPosition = box.globalToLocal(
                    details.globalPosition,
                  );

                  setState(() {
                    draggingItem = item;
                    dragPosition = localPosition;
                    dragOffset = Offset(
                      localPosition.dx - (item.posY * cellSize),
                      localPosition.dy - (item.posX * cellSize),
                    );
                  });
                },
                onPanUpdate: (details) {
                  final box =
                      _gridKey.currentContext!.findRenderObject() as RenderBox;

                  final localPosition = box.globalToLocal(
                    details.globalPosition,
                  );

                  setState(() {
                    dragPosition = localPosition;
                  });
                },
                onPanEnd: (_) {
                  if (draggingItem != null && dragPosition != null) {
                    final newCol =
                        ((dragPosition!.dx - dragOffset!.dx) / cellSize)
                            .round();

                    final newRow =
                        ((dragPosition!.dy - dragOffset!.dy) / cellSize)
                            .round();

                    inventoryManager.moveItem(
                      draggingItem!,
                      newRow,
                      newCol,
                    );

                    setState(() {
                      draggingItem = null;
                      dragOffset = null;
                      dragPosition = null;

                      widget.sheet.inventoryGridItems = inventoryManager
                          .exportItems();

                      widget.sheet.save();
                    });
                  }
                },
                child: Opacity(
                  opacity: isDragging ? 0.85 : 1,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade700,
                      border: Border.all(color: Colors.white70),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        item.baseItem.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  void _changeBackpack(InventoryType newType) {
    final oldItems = inventoryManager.exportItems();

    final newManager = InventoryManager(newType);

    bool failed = false;

    for (var itemJson in oldItems) {
      final item = InventoryItemInstance.fromJson(itemJson);

      final added = newManager.addItem(item);

      if (!added) {
        failed = true;
      }
    }

    setState(() {
      selectedType = newType;
      inventoryManager = newManager;

      widget.sheet.inventoryGridItems = inventoryManager.exportItems();

      widget.sheet.save();
    });

    if (failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Alguns itens não couberam na nova mochila.",
          ),
        ),
      );
    }
  }
}
