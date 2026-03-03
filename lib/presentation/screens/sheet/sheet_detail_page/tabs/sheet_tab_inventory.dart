///TODO: tornar os itens tocaveis para abrir uma aba de descrição
///ESSE ARQUIVO DA MUITO GRANDE, VAMOS CRIAR UM NOVO SO PARA OS WIDGETS DELE
///quando arrastado para cima, o item some aidna

import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/character_sheet.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_container.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_item_instance.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_manager.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_item.dart';
import 'package:guia_de_garlou_para_todas_as_magias/presentation/screens/sheet/sheet_detail_page/tabs/sheet_tab_inventory_equipment/equipment_section.dart';
import 'package:guia_de_garlou_para_todas_as_magias/widgets/medieval_card.dart';

class SheetTabInventory extends StatefulWidget {
  final CharacterSheet sheet;

  const SheetTabInventory({super.key, required this.sheet});

  @override
  State<SheetTabInventory> createState() => _SheetTabInventoryState();
}

class _SheetTabInventoryState extends State<SheetTabInventory> {
  late InventoryManager inventoryManager;
  final GlobalKey _gridKey = GlobalKey();
  InventoryType selectedType = InventoryType.mediumBackpack;
  bool isDragging = false;
  late Map<EquipmentSlot, InventoryItemInstance?> equippedItems;

  ///Mapa dos slots de equipamento
  // Map<EquipmentSlot, InventoryItemInstance?> equippedItems = {
  //   EquipmentSlot.head: null,
  //   EquipmentSlot.chest: null,
  //   EquipmentSlot.mainHand: null,
  //   EquipmentSlot.offHand: null,
  // };

  @override
  void initState() {
    super.initState();
    selectedType = InventoryType.values[widget.sheet.inventoryTypeIndex];

    inventoryManager = InventoryManager(selectedType);

    equippedItems = widget.sheet.getEquippedItemsParsed;

    if (widget.sheet.inventoryGridItems.isNotEmpty) {
      inventoryManager.importItems(widget.sheet.inventoryGridItems);
    }
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
                  final current = sheet.convertWeight(
                    inventoryManager.totalWeight,
                  );
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
                            value:
                                (inventoryManager.totalWeight /
                                        sheet.carryingCapacity)
                                    .clamp(0, 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              //Equipamento
              EquipmentSection(
                equippedItems: equippedItems,
                onItemDropped: (slot, item) {
                  print("Item dropado no slot");
                  setState(() {
                    equippedItems[slot] = item;
                    inventoryManager.removeItem(item);

                    widget.sheet.inventoryGridItems = inventoryManager
                        .exportItems();

                    widget.sheet.updateEquippedItemsFromParsed(equippedItems);
                    widget.sheet.save();
                  });
                },
                onItemRemoved: (slot) {
                  setState(() {
                    equippedItems[slot] = null;

                    widget.sheet.updateEquippedItemsFromParsed(equippedItems);
                    widget.sheet.save();
                  });
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
                height: 480,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedPadding(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(
                        bottom: isDragging ? 80 : 0,
                      ),
                      child: SizedBox(
                        height: 400,
                        child: buildInventoryGrid(),
                      ),
                    ),

                    AnimatedOpacity(
                      opacity: isDragging ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: isDragging == false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: buildTrash(),
                        ),
                      ),
                    ),
                  ],
                ),
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

                return DragTarget<InventoryItemInstance>(
                  onAcceptWithDetails: (details) {
                    final item = details.data;

                    bool moved;
                    final alreadyInGrid = inventoryManager.contains(item);

                    if (alreadyInGrid) {
                      moved = inventoryManager.moveItem(item, row, col);
                    } else {
                      moved = inventoryManager.moveItem(item, row, col);
                    }

                    if (moved) {
                      setState(() {
                        equippedItems.updateAll((key, value) {
                          return value == item ? null : value;
                        });

                        widget.sheet.inventoryGridItems = inventoryManager
                            .exportItems();

                        widget.sheet.save();
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: candidateData.isNotEmpty
                              ? Colors.green
                              : Colors.grey.shade700,
                        ),
                        color: Colors.black,
                      ),
                    );
                  },
                );
              },
            ),

            /// ITENS AGRUPADOS
            ..._buildPositionedItems(cellSize),
          ],
        );
      },
    );
  }

  // ADICIONAR ITEM AO GRID
  void addItem() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final iskg = widget.sheet.weightUnit == WeightUnit.kg;
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
              MedievalCard(
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
              ),
              const SizedBox(height: 12),
              MedievalCard(
                child: TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: iskg ? "Peso (kg)" : "Peso (lb)",
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: widthController,
                decoration: const InputDecoration(
                  labelText: "Largura (grid)",
                  enabledBorder: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: "Altura (grid)",
                  enabledBorder: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              double enteredWeight =
                  double.tryParse(weightController.text) ?? 0;
              final quantity = int.tryParse(quantityController.text) ?? 1;
              final width = int.tryParse(widthController.text) ?? 1;
              final height = int.tryParse(heightController.text) ?? 1;

              final weightInLb = iskg
                  ? enteredWeight / 0.453592
                  : enteredWeight;

              if (name.isEmpty) return;

              final newItem = InventoryItemInstance(
                baseItem: InventoryItem(
                  name: name,
                  weight: weightInLb,
                  quantity: quantity,
                ),
                width: width,
                height: height,
              );

              final added = inventoryManager.addItem(
                newItem,
                maxCapacity: widget.sheet.carryingCapacity,
                ignoreWeight: false, //Se true permite que passe do peso maximo
              );

              if (!added) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Não há espaço suficiente no inventário."),
                  ),
                );
              }

              setState(() {});

              widget.sheet.inventoryGridItems = inventoryManager.exportItems();

              widget.sheet.inventoryTypeIndex = selectedType.index;

              widget.sheet.save();

              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
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

          widgets.add(
            Positioned(
              left: item.posY * cellSize,
              top: item.posX * cellSize,
              width: item.width * cellSize,
              height: item.height * cellSize,
              child: Draggable<InventoryItemInstance>(
                data: item,

                onDragStarted: () {
                  setState(() {
                    isDragging = true;
                  });
                },

                onDragEnd: (_) {
                  setState(() {
                    isDragging = false;
                  });
                },

                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    width: item.width * cellSize,
                    height: item.height * cellSize,
                    child: _buildItemVisual(item),
                  ),
                ),

                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildItemVisual(item),
                ),

                child: _buildItemVisual(item),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildItemVisual(InventoryItemInstance item) {
    return Container(
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
    );
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

      widget.sheet.inventoryTypeIndex = newType.index;

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

  Widget buildTrash() {
    return DragTarget<InventoryItemInstance>(
      onAcceptWithDetails: (details) {
        inventoryManager.removeItem(details.data);

        setState(() {
          widget.sheet.inventoryGridItems = inventoryManager.exportItems();
          widget.sheet.save();
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.redAccent
                : Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 40,
          ),
        );
      },
    );
  }
}
