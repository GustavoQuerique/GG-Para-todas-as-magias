import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_container.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_grid.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_item_instance.dart';
import 'package:guia_de_garlou_para_todas_as_magias/domain/models/inventory/inventory_controller/inventory_movement.dart';

class InventoryManager {
  late InventoryGrid grid;
  late InventoryMovement movement;

  InventoryManager(InventoryType type) {
    final container = InventoryContainer.create(type);
    grid = InventoryGrid(container);
    movement = InventoryMovement(container: grid.container, grid: grid.grid);
  }

  ///Novo addItem que bloqueia se passar do peso
  bool addItem(
    InventoryItemInstance item, {
    double? maxCapacity,
    bool ignoreWeight = false,
  }) {
    //Regra de peso
    if (!ignoreWeight && maxCapacity != null) {
      if (totalWeight + item.baseItem.totalWeight > maxCapacity) {
        return false;
      }
    }

    //Regra espacial
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

  void removeItem(InventoryItemInstance item) {
    for (int r = 0; r < grid.container.rows; r++) {
      for (int c = 0; c < grid.container.columns; c++) {
        if (grid.grid[r][c] == item) {
          grid.grid[r][c] = null;
        }
      }
    }
  }

  double get totalWeight {
    final uniqueItems = <InventoryItemInstance>{};

    for (var row in grid.grid) {
      for (var cell in row) {
        if (cell != null) {
          uniqueItems.add(cell);
        }
      }
    }

    double sum = 0;

    for (var item in uniqueItems) {
      sum += item.baseItem.totalWeight;
    }

    return sum;
  }

  bool contains(InventoryItemInstance item) {
    for (var row in grid.grid) {
      for (var cell in row) {
        if (cell == item) return true;
      }
    }
    return false;
  }
}
