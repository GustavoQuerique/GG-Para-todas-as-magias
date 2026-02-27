import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_container.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_grid.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_item_instance.dart';
import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_controller/inventory_movement.dart';

class InventoryManager {
  late InventoryGrid grid;
  late InventoryMovement movement;

  InventoryManager(InventoryType type) {
    final container = InventoryContainer.create(type);
    grid = InventoryGrid(container);
    movement = InventoryMovement(container: grid.container, grid: grid.grid);
  }

  bool addItem(InventoryItemInstance item) {
    for (int row = 0; row < grid.container.rows; row++) {
      for (int col = 0; col < grid.container.columns; col++) {
        if (grid.canPlaceItem(item, row, col)) {
          return grid.placeItem(item, row, col);
        }
      }
    }
    return false;
  }

  bool moveItem(
    InventoryItemInstance item,
    int newRow,
    int newCol,
  ) {
    return movement.moveItem(item, newRow, newCol);
  }

  List<Map<String, dynamic>> exportItems() {
    final items = <InventoryItemInstance>{};

    for (var row in grid.grid) {
      for (var cell in row) {
        if (cell != null) {
          items.add(cell);
        }
      }
    }

    return items.map((e) => e.toJson()).toList();
  }

  void importItems(List<dynamic> jsonList) {
    for (var itemJson in jsonList) {
      final item = InventoryItemInstance.fromJson(
        Map<String, dynamic>.from(itemJson),
      );

      movement.placeItem(item, item.posX, item.posY);
    }
  }
}
