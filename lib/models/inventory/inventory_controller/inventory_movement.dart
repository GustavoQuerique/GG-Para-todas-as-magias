import 'inventory_item_instance.dart';
import 'inventory_container.dart';

class InventoryMovement {
  final InventoryContainer container;
  final List<List<InventoryItemInstance?>> grid;

  InventoryMovement({
    required this.container,
    required this.grid,
  });

  bool moveItem(
    InventoryItemInstance item,
    int newRow,
    int newCol,
  ) {
    if (!canPlaceItem(item, newRow, newCol)) {
      return false;
    }

    clearItemFromGrid(item);
    placeItem(item, newRow, newCol);

    return true;
  }

  bool canPlaceItem(
    InventoryItemInstance item,
    int row,
    int col,
  ) {
    if (row + item.height > container.rows ||
        col + item.width > container.columns) {
      return false;
    }

    for (int r = 0; r < item.height; r++) {
      for (int c = 0; c < item.width; c++) {
        final existing = grid[row + r][col + c];

        if (existing != null && existing != item) {
          return false;
        }
      }
    }

    return true;
  }

  void clearItemFromGrid(InventoryItemInstance item) {
    for (int r = 0; r < container.rows; r++) {
      for (int c = 0; c < container.columns; c++) {
        if (grid[r][c] == item) {
          grid[r][c] = null;
        }
      }
    }
  }

  void placeItem(
    InventoryItemInstance item,
    int row,
    int col,
  ) {
    for (int r = 0; r < item.height; r++) {
      for (int c = 0; c < item.width; c++) {
        grid[row + r][col + c] = item;
      }
    }

    item.posX = row;
    item.posY = col;
  }
}
