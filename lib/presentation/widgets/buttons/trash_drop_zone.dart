import 'package:flutter/material.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_item.dart';

class TrashDropZone extends StatelessWidget {
  final Function(InventoryItem) onItemDropped;
  final bool isDragging;

  const TrashDropZone({
    super.key,
    required this.onItemDropped,
    required this.isDragging,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<InventoryItem>(
      onAcceptWithDetails: (details) {
        onItemDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: isHovering
                ? Colors.red.shade700
                : isDragging
                ? Colors.red.shade300
                : Colors.grey.shade800,
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
