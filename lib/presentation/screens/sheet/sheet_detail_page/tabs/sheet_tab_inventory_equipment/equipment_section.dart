import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_item_instance.dart';

enum EquipmentSlot {
  head,
  mainHand,
  offHand,
  chest,
}

class EquipmentSection extends StatelessWidget {
  final Map<EquipmentSlot, InventoryItemInstance?> equippedItems;
  final Function(EquipmentSlot, InventoryItemInstance) onItemDropped;
  final Function(EquipmentSlot) onItemRemoved;

  const EquipmentSection({
    super.key,
    required this.equippedItems,
    required this.onItemDropped,
    required this.onItemRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        const Text(
          "Equipamento",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        _buildSlot(EquipmentSlot.head, "Cabeça"),

        const SizedBox(height: 16),

        _buildSlot(EquipmentSlot.chest, "Peito"),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSlot(EquipmentSlot.offHand, "Mão Esq."),
            const SizedBox(width: 24),
            _buildSlot(EquipmentSlot.mainHand, "Mão Dir."),
          ],
        ),
      ],
    );
  }

  ///cria os slots do equipamento, e atualiza eles caso tenha item ou não
  Widget _buildSlot(
    EquipmentSlot slot,
    String label,
  ) {
    final item = equippedItems[slot];

    return DragTarget<InventoryItemInstance>(
      onWillAcceptWithDetails: (_) => true,

      onAcceptWithDetails: (details) {
        onItemDropped(slot, details.data);
      },
      builder: (context, candidateData, rejectedData) {
        Widget content;

        if (item == null) {
          content = Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          );
        } else {
          content = Draggable<InventoryItemInstance>(
            data: item,
            onDragStarted: () {
              onItemRemoved(slot);
            },

            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 90,
                height: 90,
                child: _buildItemVisual(item),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildItemVisual(item),
            ),
            child: _buildItemVisual(item),
          );
        }

        return Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.greenAccent
                  : Colors.white70,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: item == null
                ? Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  )
                : content, //USA O DRAGGABLE AQUI
          ),
        );
      },
    );
  }

  Widget _buildItemVisual(InventoryItemInstance item) {
    return Container(
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
}
